defmodule ECSx.Persistence do
  def persist_components(opts \\ []) do
    component_map =
      ECSx.manager().components()
      |> Enum.map(fn component_module ->
        {component_module, component_module.get_all_persist()}
      end)
      |> Enum.filter(&(length(elem(&1, 1)) > 0))

    ECSx.Persistence.Server.persist_components(component_map, opts)
  end

  def retrieve_components(opts \\ []) do
    case persistence_adapter().retrieve_components(opts) do
      {:ok, component_map} ->
        Enum.map(component_map, fn {component_module, components} ->
          Enum.map(components, &component_module.load/1)
        end)

        :ok

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
