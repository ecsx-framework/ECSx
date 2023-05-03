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

  ## `setup` block

  Another important piece of the Manager module is the `setup` block.  Here you can load
  all the necessary data for your app before any Systems run or users connect.  See `setup/1`
  for more information.
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

        {:ok, [], {:continue, :start_systems}}
      end

      def handle_continue(:start_systems, state) do
        case ECSx.Persistence.retrieve_components() do
          :ok ->
            Logger.info("Retrieved Components")
            startup()

          {:error, :fresh_server} ->
            Logger.info("Fresh server detected")

            setup()
            startup()

          {:error, reason} ->
            Logger.warn("Failed to retrieve components: #{inspect(reason)}")
            setup()
            startup()
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
  `setup` and `startup`
  The setup function runs during the *first* server startup. The `startup` function runs during *every* server startup,
  including the first server startup (after `setup` is run). The manager uses the Persistence layer to determine if this
  is a fresh server or a subsequent start.

  The functions will be run during the Manager's initialization. The Component tables will be created before they are
  executed.

  ## Example

  ```
  defmodule YourApp.Manager do
    use ECSx.Manager

    def setup do
      for tree <- YourApp.Map.trees() do
        YourApp.Components.Location.add(tree.id, tree.location)
        YourApp.Components.Type.add(tree.id, "Tree")
      end
      for rock <- YourApp.Map.rocks() do
        YourApp.Components.Location.add(rock.id, rock.location)
        YourApp.Components.Type.add(rock.id, "Rock")
      end

      :ok
    end

    def startup do
      for spawn_location <- YourApp.spawn_locations() do
        YourApp.Components.SpawnLocation.add(spawn_location.id)
        YourApp.Components.Type.add(spawn_location.id, spawn_location.type)
        YourApp.Components.Location.add(spawn_location.id, spawn_location.spawn_location)
      end

      :ok
    end
  end
  ```

  This setup will spawn each NPC with Components for Name, HitPoints, and Location.
  """
  @callback setup() :: :ok
  @callback startup() :: :ok

  @doc false
  def start_link(module) do
    GenServer.start_link(module, [], name: module)
  end
end
