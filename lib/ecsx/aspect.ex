defmodule ECSx.Aspect do
  @moduledoc """
  Aspects provide an API for working with Components of a specific type.

  For example, if Entities in your application should have a "color" value, you will
  create an Aspect called `Color`.  This allows you to add a color Component to an Entity
  with `add/1`, query the color value for a given Entity with `get/1` or `get_value/2`,
  query all Entities which have a color value with `get_all/0`, remove the color value
  from an Entity altogether with `remove/1`, or test whether an entity has a color with
  `has_component?/1`.

  ## Usage

  Each Aspect should have its own module, which defines a schema for the data, and optional
  ETS table settings.  The schema defines the field names which will be used to reference
  each value.

      defmodule MyApp.Component.Color do
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

  ### Example

      defmodule TakingDamageOverTime do
        use ECSx.Aspect,
          schema: {:entity_id, :damage_per_second, :damage_type, :source_id}
      end

      alias TakingDamageOverTime, as: DOT

      DOT.add(entity_id: hero.id, damage_per_second: 10, type: :poison, source_id: spider.id)
      DOT.add(entity_id: hero.id, damage_per_second: 25, type: :fire, source_id: dragon.id)

      DOT.get(hero.id)
      [%{entity_id: ...}, %{...}]

      DOT.get_value(hero.id, :damage_per_second)
      [10, 25]

  ## `get/1` and `get_value/2`

  The standard way to fetch the component(s) from an Entity is using `MyAspect.get(entity_id)`.
  If your `table_type` is `:set` or `:ordered_set`, this function will return a single
  Component, or `nil` if the Entity does not have that Aspect.  If the `table_type` is `:bag`
  or `:duplicate_bag`, then it will return a list containing zero or more Components.

  Each Component is represented by a map, using the keys provided by the schema.  If you only
  want a single value from the Component, use `get_value/2`, passing the field name of the
  desired value as the second argument.

  ### Examples

      Color.get(entity_id)
      %{entity_id: entity_id, hue: 300, saturation: 50, lightness: 45}

      Color.get_value(entity_id, :hue)
      300

  """

  @type t :: map
  @type id :: any
  @type value :: any
  @type aspect :: atom

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.Aspect

      @schema Keyword.fetch!(opts, :schema)
      @fields Tuple.to_list(@schema)
      # TODO: what if table_type is invalid?
      @table_type opts[:table_type] || :set
      @table_name opts[:table_name] || __MODULE__
      @concurrency {:read_concurrency, opts[:read_concurrency] || false}

      def init do
        :ets.new(@table_name, [:named_table, @table_type, @concurrency])
        :ok
      end

      def add(attrs) do
        row =
          @fields
          |> Enum.map(&Keyword.fetch!(attrs, &1))
          |> List.to_tuple()

        :ets.insert(@table_name, row)
        :ok
      end

      if @table_type in ~w(set ordered_set)a do
        def get(entity_id) do
          case :ets.lookup(@table_name, entity_id) do
            [] -> nil
            [object] -> ECSx.Component.mapify(object, @fields)
          end
        end

        def get_value(entity_id, field) do
          case :ets.lookup(@table_name, entity_id) do
            [] -> nil
            [object] -> ECSx.Component.parse_field(object, @fields, field)
          end
        end
      else
        def get(entity_id) do
          @table_name
          |> :ets.lookup(entity_id)
          |> Enum.map(&ECSx.Component.mapify(&1, @fields))
        end

        def get_value(entity_id, field) do
          @table_name
          |> :ets.lookup(entity_id)
          |> Enum.map(&ECSx.Component.parse_field(&1, @fields, field))
        end
      end

      def get_all do
        @table_name
        |> :ets.tab2list()
        |> Enum.map(&ECSx.Component.mapify(&1, @fields))
      end

      def remove(entity_id) do
        :ets.delete(@table_name, entity_id)
        :ok
      end

      def has_component?(entity_id), do: :ets.member(@table_name, entity_id)
    end
  end

  @doc """
  Initializes the ETS table to store all components of this aspect.
  """
  @callback init() :: :ok

  @doc """
  Creates a new component.

  ## Example

      ECSx.Component.add(ArmorRating, entity_id: 123, value: 10)

  """
  @callback add(attrs :: Keyword.t()) :: :ok

  @doc """
  Gets an existing Component from the table, given its entity ID.
  """
  @callback get(entity_id :: any) :: t

  @doc """
  Gets a single value from a component.
  """
  @callback get_value(entity_id :: any, field :: atom) :: value

  @doc """
  Gets all existing components of this aspect.
  """
  @callback get_all() :: [t]

  @doc """
  Removes any existing components of this aspect from an entity.
  """
  @callback remove(entity_id :: any) :: :ok

  @doc """
  Checks if an entity has one or more components with this aspect.
  """
  @callback has_component?(entity_id :: any) :: boolean
end
