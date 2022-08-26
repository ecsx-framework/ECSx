defmodule ECSx.Aspect do
  @moduledoc """
  Provides an API for working with Components of a specific type.

  For example, if Entities in your application should have a "color" value, you will
  create an Aspect called `Color`.  This allows you to add a color Component to an Entity
  with `add_component/1`, query the color value for a given Entity with `query_one/1`,
  query all Entities which have a color value with `query_all/1`, remove
  the color value from an Entity altogether with `remove_component/1`, or test whether
  an entity has a color with `has_component?/1`.

  ## Usage

  Each Aspect should have its own module, which defines a schema for the data, and optional
  ETS table settings.  The schema defines the field names which will be used to reference
  each value.

      defmodule MyApp.Aspects.Color do
        use ECSx.Aspect,
          schema: {:entity_id, :hue, :saturation, :lightness}
      end

  ### Options

    * `:schema` - a tuple of field names
    * `:table_type` - ETS table type.  Possible options are `:set`, `:ordered_set`, `:bag`, and
      `:duplicate_bag`.  Defaults to `:set`.  See below for more information.
    * `:read_concurrency` - when `true`, enables read concurrency for the ETS table.  Defaults
      to `false`

  ## `:table_type` option

  By default, ECSx creates ETS tables of type `:set` for your Components.  This means that
  each Entity may have at most one Component of each Aspect.  For example, if your application
  has a "Height" Aspect, Entities would never need more than one Component to model that value.
  However, if you had an Aspect such as "TakingDamageOverTime", you might want an Entity to
  store each source of damage as a separate value, using multiple Components of the same Aspect.
  To do this, set `:table_type` to `:bag`.

  ### Example

      defmodule TakingDamageOverTime do
        use ECSx.Aspect,
          schema: {:entity_id, :damage_per_second, :damage_type, :source_id},
          table_type: :bag
      end

      alias TakingDamageOverTime, as: DOT

      DOT.add_component(entity_id: hero.id, damage_per_second: 10, type: :poison, source_id: spider.id)
      DOT.add_component(entity_id: hero.id, damage_per_second: 25, type: :fire, source_id: dragon.id)

  ## `query_one/1` and `query_all/1`

  The standard way to fetch the Component(s) from an Entity is using a Query.  Each aspect
  provides two Query functions: `query_one/1` and `query_all/1`.  The former returns a single
  result, and will raise an `ECSx.QueryError` if more than one result is found.  The latter
  will return a list with any number of results.

  These Query functions have two possible parameters:

    * `:match` - A keyword list of the fields and values for which to search.  If a `:match` is
      not given, the entire Aspect table will be returned.

    * `:value` - By default, each Component returned by a Query will be in the form of a map,
      using the keys provided by its Aspect schema.  If you only care about one field from the
      Component, you can instead return unwrapped values with `value: :field_name`

  ### Examples

      Color.query_one(match: [entity_id: entity_id])
      %{entity_id: entity_id, hue: 300, saturation: 50, lightness: 45}

      Color.query_one(match: [entity_id: entity_id], value: :hue)
      300

      Color.query_all()
      [%{entity_id: entity_id, ...}, %{...}, ...]

      Color.query_all(value: :entity_id)
      [entity_id, another_entity_id, ...]

  """
  @type t :: module

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.Aspect

      @schema Keyword.fetch!(opts, :schema)
      @fields Tuple.to_list(@schema)
      # TODO: what if table_type is invalid?
      @table_type opts[:table_type] || :set
      @table_name opts[:table_name] || __MODULE__
      @concurrency {:read_concurrency, opts[:read_concurrency] || false}

      def init, do: ECSx.Aspect.init(@table_name, @table_type, @concurrency)

      def add_component(attrs), do: ECSx.Component.add(@table_name, attrs, @fields)

      def query_one(query \\ []), do: ECSx.Component.query_one(@table_name, @fields, query)

      def query_all(query \\ []), do: ECSx.Component.query_all(@table_name, @fields, query)

      def remove_component(entity_id), do: ECSx.Component.remove(@table_name, entity_id)

      def has_component?(entity_id), do: ECSx.Component.exists?(@table_name, entity_id)
    end
  end

  @doc """
  Initializes the ETS table to store all components of this aspect.
  """
  @callback init() :: :ok

  @doc """
  Creates a new component.

  ## Example

      ArmorRating.add_component(entity_id: 123, value: 10)

  """
  @callback add_component(attrs :: Keyword.t()) :: :ok

  @doc """
  Query for a single component of this aspect with optional match conditions.

  Raises if more than one component is returned.

  Examples

      # Get the Velocity component for entity 123
      Velocity.query_one(match: [entity_id: 123])

  """
  @callback query_one(query :: Keyword.t()) :: ECSx.Component.t() | ECSx.Component.value()

  @doc """
  Query for all components of this aspect with optional match conditions.

  Examples

      # Get the ID of each entity with zero velocity in the x-y plane
      Velocity.query_all(match: [vx: 0, vy: 0], value: :entity_id)

  """
  @callback query_all(query :: Keyword.t()) :: [ECSx.Component.t() | ECSx.Component.value()]

  @doc """
  Removes any existing components of this aspect from an entity.
  """
  @callback remove_component(entity_id :: any) :: :ok

  @doc """
  Checks if an entity has one or more components with this aspect.
  """
  @callback has_component?(entity_id :: any) :: boolean

  @doc false
  def init(table_name, table_type, concurrency) do
    :ets.new(table_name, [:named_table, table_type, concurrency])
    :ok
  end
end
