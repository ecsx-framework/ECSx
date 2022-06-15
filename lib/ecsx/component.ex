defmodule ECSx.Component do
  @moduledoc """
  Components.
  """

  @type t :: tuple | map | value
  @type value :: any

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.Component

      @schema Keyword.fetch!(opts, :schema)
      @row_length tuple_size(@schema)
      @fields Tuple.to_list(@schema)
      @get_select opts[:get_select] || [all: :map]
      @table_name opts[:table_name] || __MODULE__
      @table_type opts[:table_type] || :set
      @concurrency {:read_concurrency, opts[:read_concurrency] || false}

      def __init__ do
        :ets.new(@table_name, [:named_table, @table_type, @concurrency])
      end

      def add(attrs) do
        ECSx.Component.add(@table_name, attrs, @fields)
      end

      if @table_type in ~w(set ordered_set)a do
        def get(entity_id, opts \\ []) do
          select = Keyword.get(opts, :select, @get_select)
          ECSx.Component.get_one(@table_name, entity_id, @fields, select)
        end
      else
        def get(entity_id, opts \\ []) do
          select = Keyword.get(opts, :select, @get_select)
          ECSx.Component.get_many(@table_name, entity_id, @fields, select)
        end
      end

      def get_all(opts \\ []) do
        select = Keyword.get(opts, :select, all: :tuple)
        ECSx.Component.get_all(@table_name, @fields, select)
      end

      def remove(entity_id) do
        :ets.delete(@table_name, entity_id)
        :ok
      end

      def has_component?(entity_id), do: :ets.member(@table_name, entity_id)
    end
  end

  @doc """
  Initializes the Component table.
  """
  @callback __init__() :: atom

  @doc """
  Adds a new Component to the table.
  """
  @callback add(attrs :: Keyword.t()) :: :ok

  @doc """
  Gets an existing Component from the table, given its entity ID.

  ## Options

  * `:select` - The return format for the Component. This will overwrite the
    default value for `:get_select`.

  ## Example

      NameComponent.get(123)

      NameComponent.get(123, select: [field: :name])

  """
  @callback get(id :: any, opts :: Keyword.t()) :: t

  @doc """
  Gets all Components from the table.

  ## Options

  * `:select` - The return format for the Components.  Defaults to `[all: :tuple]`.

  ## Example

      NameComponent.get_all()

      NameComponent.get_all(select: [all: :map])
      
  """
  @callback get_all(opts :: Keyword.t()) :: t

  @doc """
  Removes an existing Component from the table, given its entity ID.
  """
  @callback remove(id :: any) :: :ok

  @doc """
  Checks if an entity has one or more of the Component.
  """
  @callback has_component?(id :: any) :: boolean

  def add(table_name, attrs, fields) do
    row =
      fields
      |> Enum.map(&Keyword.fetch!(attrs, &1))
      |> List.to_tuple()

    :ets.insert(table_name, row)
    :ok
  end

  def get_one(table_name, entity_id, fields, select) do
    case :ets.lookup(table_name, entity_id) do
      [] -> nil
      [object] -> process_result(object, fields, select)
    end
  end

  def get_many(table_name, entity_id, fields, select) do
    table_name
    |> :ets.lookup(entity_id)
    |> Enum.map(&process_result(&1, fields, select))
  end

  def get_all(table_name, fields, select) do
    table_name
    |> :ets.tab2list()
    |> Enum.map(&process_result(&1, fields, select))
  end

  defp process_result(object, fields, [{:all, :map}]) do
    values = Tuple.to_list(object)

    fields
    |> Enum.zip(values)
    |> Map.new()
  end

  defp process_result(object, _, [{:all, :tuple}]), do: object

  defp process_result(_object, _fields, [{:fields, select}]) when is_list(select) do
    nil
  end

  defp process_result(object, fields, [{:field, select}]) do
    index = Enum.find_index(fields, &(&1 == select))

    elem(object, index)
  end
end
