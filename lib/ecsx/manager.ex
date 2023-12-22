defmodule ECSx.Manager do
  @moduledoc """
  The Manager for your ECSx application.

  In an ECSx application, the Manager is responsible for:

    * starting up ETS tables for each Component Type, where the Components will be stored
    * prepopulating the game content into memory
    * keeping track of the Systems to run, and their run order
    * running the Systems every tick

  ## `components/0` and `systems/0`

  Your Manager module must contain two zero-arity functions called `components` and `systems`
  which return a list of all Component Types and Systems in your application.  The order of
  the Component Types list is irrelevant, but the order of the Systems list is very important,
  because the Systems are run consecutively in the given order.

  ## `setup/0` and `startup/0`

  Manager modules may also implement two optional functions for loading all the necessary
  component data for your app before any Systems run or users connect.

  The `setup/0` function runs only *once*, when you start your app for the first time, while
  the `startup/0` function runs *every* time the app starts, including the first
  (after `setup/0` is run). The Manager uses the Persistence layer to determine if this
  is a fresh server or a subsequent start.

  These functions will be run during the Manager's initialization. The Component tables
  will be created before they are executed.

  ## Example

  ```
  defmodule YourApp.Manager do
    use ECSx.Manager

    def setup do
      for tree <- YourApp.Map.trees() do
        YourApp.Components.XPosition.add(tree.id, tree.x_coord, persist: true)
        YourApp.Components.YPosition.add(tree.id, tree.y_coord, persist: true)
        YourApp.Components.Type.add(tree.id, "Tree", persist: true)
      end
    end

    def startup do
      for spawn_location <- YourApp.spawn_locations() do
        YourApp.Components.SpawnLocation.add(spawn_location.id)
        YourApp.Components.Type.add(spawn_location.id, spawn_location.type)
        YourApp.Components.XPosition.add(spawn_location.id, spawn_location.x_coord)
        YourApp.Components.YPosition.add(spawn_location.id, spawn_location.y_coord)
      end
    end
  end
  ```
  """

  defmacro __using__(_opts) do
    quote do
      use GenServer

      import ECSx.Manager

      @behaviour ECSx.Manager

      require Logger

      def setup, do: :ok
      def startup, do: :ok
      defoverridable setup: 0, startup: 0

      def start_link(_), do: ECSx.Manager.start_link(__MODULE__)

      def init(_) do
        Enum.each(components(), fn module -> module.init() end)
        Logger.info("Component tables initialized")

        {:ok, [], {:continue, :start_systems}}
      end

      def handle_continue(:start_systems, state) do
        case ECSx.Persistence.retrieve_components() do
          :ok ->
            Logger.info("Retrieved Components")
            startup()
            Logger.info("`startup/0` complete")

          {:error, :fresh_server} ->
            Logger.info("Fresh server detected")

            setup()
            Logger.info("`setup/0` complete")
            startup()
            Logger.info("`startup/0` complete")

          {:error, reason} ->
            Logger.warning("Failed to retrieve components: #{inspect(reason)}")
            setup()
            Logger.info("`setup/0` complete")
            startup()
            Logger.info("`startup/0` complete")
        end

        tick_interval = div(1000, ECSx.tick_rate())
        :timer.send_interval(tick_interval, :tick)
        :timer.send_interval(ECSx.persist_interval(), :persist)

        {:noreply, state}
      end

      def handle_info(:tick, state) do
        Enum.each(systems(), fn system ->
          start_time = System.monotonic_time()
          system.run()
          duration = System.monotonic_time() - start_time
          measurements = %{duration: duration}
          metadata = %{system: system}
          :telemetry.execute([:ecsx, :system_run], measurements, metadata)
        end)

        {:noreply, state}
      end

      def handle_info(:persist, state) do
        ECSx.Persistence.persist_components()
        {:noreply, state}
      end
    end
  end

  @doc """
  Loads component data for first app launch.

  This will run only once, the first time you start your app.  It runs after component tables
  have been initialized, before any systems have started.

  Except for very rare circumstances, all components added here should have `persist: true`
  """
  @callback setup() :: any()

  @doc """
  Loads ephemeral component data each time the app is started.

  This will run on your app's first start (after `setup/0`) and then again during all subsequent
  app reboots.  It runs after component tables have been initialized, before any systems have started.

  Except for very rare circumstances, components added here should *not* be persisted.
  """
  @callback startup() :: any()

  @doc false
  def start_link(module) do
    GenServer.start_link(module, [], name: module)
  end
end
