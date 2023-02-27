defmodule ECSx.Base do
  @moduledoc false

  def add(component_type, component) do
    execute_telemetry(:write, component_type)
    :ets.insert(component_type, component)
    :ok
  end

  def get_one(component_type, entity_id) do
    execute_telemetry(:lookup, component_type)

    case :ets.lookup(component_type, entity_id) do
      [] ->
        nil

      [{_, value}] ->
        value

      multiple_results ->
        raise ECSx.MultipleResultsError,
          message: "get_one expects zero or one results, got #{length(multiple_results)}",
          entity_id: entity_id
    end
  end

  def get_all(component_type) do
    execute_telemetry(:scan, component_type)
    :ets.tab2list(component_type)
  end

  def get_all(component_type, entity_id) do
    execute_telemetry(:lookup, component_type)

    component_type
    |> :ets.lookup(entity_id)
    |> Enum.map(&elem(&1, 1))
  end

  def get_all_keys(component_type) do
    execute_telemetry(:scan, component_type)

    component_type
    |> :ets.tab2list()
    |> Enum.map(&elem(&1, 0))
  end

  def search(component_type, value) do
    execute_telemetry(:scan, component_type)

    component_type
    |> :ets.match({:"$1", value})
    |> List.flatten()
  end

  def remove(component_type, entity_id) do
    execute_telemetry(:write, component_type)
    :ets.delete(component_type, entity_id)
    :ok
  end

  def remove_one(component_type, entity_id, value) do
    execute_telemetry(:write, component_type)
    :ets.delete_object(component_type, {entity_id, value})
    :ok
  end

  def exists?(component_type, entity_id) do
    execute_telemetry(:lookup, component_type)
    :ets.member(component_type, entity_id)
  end

  def init(table_name, table_type, concurrency) do
    :ets.new(table_name, [:named_table, table_type, concurrency])
    :ok
  end

  defp execute_telemetry(action, component_type) do
    measurements = %{second: System.monotonic_time(:second)}
    metadata = %{type: component_type}

    :telemetry.execute([:ecsx, :component, action], measurements, metadata)
  end
end
