defmodule ECSx.Tag do
  @moduledoc """
  A component type which does not require a value.  This is useful when the mere presence or absence of a component is all the information we need.

  For example, if we want a component type to model a boolean attribute, such as whether or not players may target a particular entity, we'll use a Tag:

      defmodule MyApp.Components.Targetable do
        use ECSx.Tag
      end

  Then we can check for targetability with `...Targetable.exists?(entity)` or get a list of all targetable entities with `...Targetable.get_all()`.

  ### Options

    * `:read_concurrency` - when `true`, enables read concurrency for this component table.  Only set this if you know what you're doing.  Defaults to `false`

  """

  @type id :: any

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.Tag

      @table_type :set
      @table_name __MODULE__
      @concurrency {:read_concurrency, opts[:read_concurrency] || false}

      def init, do: ECSx.Base.init(@table_name, @table_type, @concurrency)

      def add(entity_id), do: ECSx.Base.add(@table_name, {entity_id})

      def get_all, do: ECSx.Base.get_all_keys(@table_name)

      def remove(entity_id), do: ECSx.Base.remove(@table_name, entity_id)

      def exists?(entity_id), do: ECSx.Base.exists?(@table_name, entity_id)
    end
  end

  @doc """
  Creates a new tag for a given entity.
  """
  @callback add(entity :: id) :: :ok

  @doc """
  Gets a list of all entities with this tag.
  """
  @callback get_all() :: [id]

  @doc """
  Removes this component from an entity.
  """
  @callback remove(entity :: id) :: :ok

  @doc """
  Checks if an entity has this tag.
  """
  @callback exists?(entity :: id) :: boolean
end
