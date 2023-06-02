defmodule ECSx.Persistence do
  @moduledoc false

  def persist_components(opts \\ []) do
    ECSx.manager().components()
    |> Enum.map(fn component_module ->
      {component_module, component_module.get_all_persist()}
    end)
    |> Enum.filter(&(length(elem(&1, 1)) > 0))
    |> Map.new()
    |> ECSx.Persistence.Server.persist_components(opts)
  end

  def retrieve_components(opts \\ []) do
    case persistence_adapter().retrieve_components(opts) do
      {:ok, component_map} ->
        Enum.each(component_map, fn {component_module, components} ->
          Enum.each(components, &component_module.load/1)
        end)

      {:error, :fresh_server} ->
        {:error, :fresh_server}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def persistence_adapter do
    Application.get_env(:ecsx, :persistence_adapter, ECSx.Persistence.FileAdapter)
  end
end
