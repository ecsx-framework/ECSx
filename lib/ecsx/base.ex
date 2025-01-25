defmodule ECSx.Base do
  @moduledoc false

  require Logger

  def add(component_type, id, value, opts) do
    persist = Keyword.get(opts, :persist, false)

    case :ets.lookup(component_type, id) do
      [] ->
        if Keyword.get(opts, :log_edits) do
          Logger.debug("#{component_type} add #{inspect(id)}: #{inspect(value)}")
        end

        if Keyword.get(opts, :index) do
          index_table = Module.concat(component_type, "Index")
          :ets.insert(index_table, {value, id, persist})
        end

        :ets.insert(component_type, {id, value, persist})
        :ok

      _ ->
        raise ECSx.AlreadyExistsError,
          message: "`add` expects component to not exist yet",
          entity_id: id
    end
  end

  # Direct load for persistence
  def load(component_type, component) do
    :ets.insert(component_type, component)
  end

  def update(component_type, id, value, opts) do
    if Keyword.get(opts, :log_edits) do
      Logger.debug("#{component_type} update #{inspect(id)}: #{inspect(value)}")
    end

    case :ets.lookup(component_type, id) do
      [{id, old_value, persist}] ->
        if Keyword.get(opts, :index) do
          index_table = Module.concat(component_type, "Index")
          :ets.delete_object(index_table, {old_value, id, persist})
          :ets.insert(index_table, {value, id, persist})
        end

        :ets.insert(component_type, {id, value, persist})
        :ok

      [] ->
        raise ECSx.NoResultsError,
          message: "`update` expects an existing value",
          entity_id: id
    end
  end

  def get(component_type, entity_id, default) do
    case :ets.lookup(component_type, entity_id) do
      [] ->
        case default do
          :raise ->
            raise ECSx.NoResultsError,
              message: "`get` expects one result, got 0",
              entity_id: entity_id

          other ->
            other
        end

      [component] ->
        elem(component, 1)
    end
  end

  def get_all(component_type) do
    component_type
    |> :ets.tab2list()
    |> Enum.map(&{elem(&1, 0), elem(&1, 1)})
  end

  def get_all(component_type, entity_id) do
    component_type
    |> :ets.lookup(entity_id)
    |> Enum.map(&elem(&1, 1))
  end

  def get_all_persist(component_type) do
    component_type
    |> :ets.tab2list()
    |> Enum.filter(&elem(&1, 2))
  end

  def get_all_keys(component_type) do
    component_type
    |> :ets.tab2list()
    |> Enum.map(&elem(&1, 0))
  end

  def search(component_type, value, opts) do
    if Keyword.get(opts, :index) do
      component_type
      |> Module.concat("Index")
      |> :ets.lookup(value)
      |> Enum.map(fn {_value, id, _persist} -> id end)
    else
      component_type
      |> :ets.match({:"$1", value, :_})
      |> List.flatten()
    end
  end

  def between(component_type, min, max) do
    :ets.select(component_type, [
      {{:"$1", :"$2", :_}, [{:>=, :"$2", min}, {:"=<", :"$2", max}], [{{:"$1", :"$2"}}]}
    ])
  end

  def at_least(component_type, min) do
    :ets.select(component_type, [{{:"$1", :"$2", :_}, [{:>=, :"$2", min}], [{{:"$1", :"$2"}}]}])
  end

  def at_most(component_type, max) do
    :ets.select(component_type, [{{:"$1", :"$2", :_}, [{:"=<", :"$2", max}], [{{:"$1", :"$2"}}]}])
  end

  def remove(component_type, entity_id, opts) do
    if Keyword.get(opts, :log_edits) do
      Logger.debug("#{component_type} remove #{inspect(entity_id)}")
    end

    if Keyword.get(opts, :index) do
      case :ets.lookup(component_type, entity_id) do
        [{^entity_id, value, persist}] ->
          index_table = Module.concat(component_type, "Index")
          :ets.delete(component_type, entity_id)
          :ets.delete_object(index_table, {value, entity_id, persist})

        _ ->
          nil
      end
    else
      :ets.delete(component_type, entity_id)
    end

    :ok
  end

  def exists?(component_type, entity_id) do
    :ets.member(component_type, entity_id)
  end

  def init(table_name, concurrency, opts) do
    :ets.new(table_name, [:named_table, :set, concurrency])

    if Keyword.get(opts, :index) do
      index_table = Module.concat(table_name, "Index")
      :ets.new(index_table, [:named_table, :bag])
    end

    :ok
  end
end
