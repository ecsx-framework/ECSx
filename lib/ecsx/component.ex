defmodule ECSx.Component do
  @moduledoc """
  A component labels an entity as possessing a particular aspect, and holds the data
  needed to model that aspect. Under the hood, we use ETS to store the components
  in memory for quick retrieval via aspect and entity ID.

  Each aspect will have its own module, which defines a schema for the data,
  the format to return the data after querying, and various ETS table settings.
  The only mandatory option is the schema, which defines the number of values
  to store and field names to reference each value.

      defmodule MyApp.Component.Color do
        use ECSx.Component,
          schema: {:entity_id, :color}
      end

  ## Options
    * `:schema` - a tuple of field names for components for this aspect.
    * `:select` - the return format for `get/3` and `get_all/2`.  Possible options are
      `[all: :map]`, `[all: :tuple]`, `[field: :foo]` and `[fields: [:foo, :bar]]`.  Defaults
      to `[all: :map]`
    * `:table_type` - ETS table type.  Possible options are `:set`, `:ordered_set`, `:bag`, and
      `:duplicate_bag`.  Defaults to `:set`
    * `:read_concurrency` - when `true`, enables read concurrency for the ETS table.  Defaults
      to `false`
  """

  @type t :: tuple | map | value
  @type id :: any
  @type value :: any
  @type aspect :: atom

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @schema Keyword.fetch!(opts, :schema)
      @fields Tuple.to_list(@schema)
      @select opts[:select] || [all: :map]
      @table_type opts[:table_type] || :set
      @concurrency {:read_concurrency, opts[:read_concurrency] || false}

      def __fields__, do: @fields

      def __table_type__, do: @table_type

      def __select__, do: @select

      def __concurrency__, do: @concurrency
    end
  end

  @doc """
  Initializes the component table for a given aspect.
  """
  @spec init(module) :: :ok
  def init(aspect) when is_atom(aspect) do
    :ets.new(aspect, [:named_table, aspect.__table_type__(), aspect.__concurrency__()])
  rescue
    UndefinedFunctionError ->
      raise ECSx.InvalidAspectModule, aspect
  end

  @doc """
  Creates a new component.

  ## Example

      ECSx.Component.add(ArmorRating, entity_id: 123, value: 10)

  """
  @spec add(atom, Keyword.t()) :: :ok
  def add(aspect, attrs) do
    row =
      aspect.__fields__()
      |> Enum.map(&Keyword.fetch!(attrs, &1))
      |> List.to_tuple()

    :ets.insert(aspect, row)
    :ok
  end

  @doc """
  Gets an existing Component from the table, given its entity ID.

  ## Options

  * `:select` - The return format for the Component. This will overwrite the
    default value for `:get_select`.

  ## Example

      ECSx.Component.get(Name, 123)

      ECSx.Component.get(Name, 123, select: [field: :first_name])

  """
  @spec get(atom, any, Keyword.t()) :: t
  def get(aspect, entity_id, opts \\ []) do
    select = Keyword.get(opts, :select, aspect.__select__())
    fields = aspect.__fields__()

    if aspect.__table_type__() in ~w(set ordered_set)a do
      get_one(aspect, entity_id, fields, select)
    else
      get_many(aspect, entity_id, fields, select)
    end
  end

  defp get_one(aspect, entity_id, fields, select) do
    case :ets.lookup(aspect, entity_id) do
      [] -> nil
      [object] -> process_result(object, fields, select)
    end
  end

  defp get_many(aspect, entity_id, fields, select) do
    aspect
    |> :ets.lookup(entity_id)
    |> Enum.map(&process_result(&1, fields, select))
  end

  @doc """
  Gets all components of a given aspect.

  ## Options

  * `:select` - The return format for the Components.  Defaults to `[all: :tuple]`.

  ## Example

      ECSx.Component.get_all(Poisoned)

      ECSx.Component.get_all(Poisoned, select: [field: :entity_id])

  """
  @spec get_all(atom, Keyword.t()) :: [t]
  def get_all(aspect, opts \\ []) do
    select = Keyword.get(opts, :select, aspect.__select__())

    aspect
    |> :ets.tab2list()
    |> Enum.map(&process_result(&1, aspect.__fields__(), select))
  end

  @doc """
  Removes any existing components of a given aspect from an entity.
  """
  @spec remove(atom, any) :: :ok
  def remove(aspect, entity_id) do
    :ets.delete(aspect, entity_id)
    :ok
  end

  @doc """
  Checks if an entity has one or more components with the given aspect.
  """
  @spec has_component?(atom, any) :: boolean
  def has_component?(aspect, entity_id) do
    :ets.member(aspect, entity_id)
  end

  defp process_result(object, fields, [{:all, :map}]) do
    values = Tuple.to_list(object)

    fields
    |> Enum.zip(values)
    |> Map.new()
  end

  defp process_result(object, _, [{:all, :tuple}]), do: object

  defp process_result(object, fields, [{:fields, select}]) when is_list(select) do
    Enum.map(select, fn field ->
      index = Enum.find_index(fields, &(&1 == field))
      elem(object, index)
    end)
    |> List.to_tuple()
  end

  defp process_result(object, fields, [{:field, select}]) do
    index = Enum.find_index(fields, &(&1 == select))

    elem(object, index)
  end
end
