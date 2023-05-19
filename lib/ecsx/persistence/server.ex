defmodule ECSx.Persistence.Server do
  @moduledoc false
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def persist_components(component_map, opts) do
    GenServer.cast(__MODULE__, {:persist, component_map, opts})
  end

  @impl GenServer
  def init(:ok) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:persist, component_map, opts}, state) do
    ECSx.Persistence.persistence_adapter().persist_components(component_map, opts)
    {:noreply, state}
  end
end
