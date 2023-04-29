defmodule ECSx.Component do
  @moduledoc """
  A Component labels an entity as having a certain attribute, and holds any data needed to model that attribute.

  For example, if Entities in your application should have a "color" value, you will create a Component type called `Color`.  This allows you to add a color component to an Entity with `add/2`, look up the color value for a given Entity with `get_one/1`, get all Entities' color values with `get_all/1`, remove the color value from an Entity altogether with `remove/1`, or test whether an entity has a color with `exists?/1`.

  Under the hood, we use ETS to store the Components in memory for quick retrieval via Entity ID.

  ## Usage

  Each Component type should have its own module, where it can be optionally configured.

      defmodule MyApp.Components.Color do
        use ECSx.Component,
          value: :binary,
          unique: true
      end

  ### Options

    * `:value` - The type of value which will be stored in this component type.  Valid types are: `:atom, :binary, :datetime, :float, :integer`
    * `:unique` - When `true`, each entity may have, at most, one component of this type;  attempting to add another will overwrite the first.  When `false`, an entity may have many components of this type.
    * `:read_concurrency` - when `true`, enables read concurrency for this component table.  Only set this if you know what you're doing.  Defaults to `false`

  """

  @type id :: any
  @type value :: any

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.Component

      @table_name __MODULE__
      @concurrency {:read_concurrency, opts[:read_concurrency] || false}
      @valid_value_types ~w(atom binary datetime float integer)a
      @component_opts [log_edits: opts[:log_edits] || false]

      @table_type (case(Keyword.get(opts, :unique, true)) do
                     true ->
                       :set

                     false ->
                       :bag

                     x ->
                       raise(
                         ArgumentError,
                         "Invalid option for `unique` - expected boolean, got: #{inspect(x)}"
                       )
                   end)

      # Sets up value type validation
      case Keyword.fetch!(opts, :value) do
        :integer ->
          defguard ecsx_type_guard(value) when is_integer(value)

        :float ->
          defguard ecsx_type_guard(value) when is_float(value)

        :binary ->
          defguard ecsx_type_guard(value) when is_binary(value)

        :atom ->
          defguard ecsx_type_guard(value) when is_atom(value)

        :datetime ->
          defguard ecsx_type_guard(value) when is_struct(value, DateTime)

        _ ->
          raise(
            ArgumentError,
            "Invalid value type:  Valid types are #{inspect(@valid_value_types)}"
          )
      end

      def init, do: ECSx.Base.init(@table_name, @table_type, @concurrency)

      def add(entity_id, value, opts \\ []) when ecsx_type_guard(value),
        do: ECSx.Base.add(@table_name, entity_id, value, Keyword.merge(opts, @component_opts))

      def load(component), do: ECSx.Base.load(@table_name, component)

      def update(entity_id, value) when ecsx_type_guard(value),
        do: ECSx.Base.update(@table_name, entity_id, value, @component_opts)

      def get_one(key, default \\ :raise), do: ECSx.Base.get_one(@table_name, key, default)

      def get_all, do: ECSx.Base.get_all(@table_name)

      def get_all(key), do: ECSx.Base.get_all(@table_name, key)

      def get_all_persist, do: ECSx.Base.get_all_persist(@table_name)

      def search(value), do: ECSx.Base.search(@table_name, value)

      def remove(entity_id), do: ECSx.Base.remove(@table_name, entity_id, @component_opts)

      def remove_one(entity_id, value),
        do: ECSx.Base.remove_one(@table_name, entity_id, value, @component_opts)

      def exists?(entity_id), do: ECSx.Base.exists?(@table_name, entity_id)
    end
  end

  @doc """
  Creates a new component.

  ## Example

      # Add an ArmorRating component to entity `123` with value `10`
      ArmorRating.add(123, 10)

  """
  @callback add(entity :: id, value :: value) :: :ok

  @doc """
  Look up a single component.

  Raises if more than one component is returned.

  ## Example

      # Get the Velocity for entity `123`
      Velocity.get_one(123)

  """
  @callback get_one(entity :: id) :: value | nil

  @doc """
  Look up all components of this type.

  ## Example

      # Get all velocity components
      Velocity.get_all()

  """
  @callback get_all() :: [{id, value}]

  @doc """
  Look up all components of this type belonging to a given entity.

  This function is only useful for component types configured with `unique: false`.
  For unique components, `get_one/1` should be used instead.

  ## Example

      # Get all PowerUp components for entity `123`
      PowerUp.get_all(123)

  """
  @callback get_all(entity :: id) :: [value]

  @doc """
  Look up all IDs for entities which have a component of this type with a given value.

  ## Example

      # Get all entities with a velocity of `60`
      Velocity.search(60)

  """
  @callback search(value :: value) :: [id]

  @doc """
  Removes any existing components of this type from an entity.
  """
  @callback remove(entity :: id) :: :ok

  @doc """
  Removes one component with a specific entity ID and value.

  This function is only useful for component types configured with `unique: false`.
  For unique components, `remove/1` should be used instead.

  ## Example

      # Remove a specific PowerUp value `9` from entity `123`
      PowerUp.remove_one(123, 9)

  """
  @callback remove_one(entity :: id, value :: value) :: :ok

  @doc """
  Checks if an entity has one or more components of this type.
  """
  @callback exists?(entity :: id) :: boolean
end
