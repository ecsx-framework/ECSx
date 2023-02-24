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

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use GenServer

      import ECSx.Manager

      def start_link(_), do: ECSx.Manager.start_link(__MODULE__)

      def init(_) do
        Enum.each(components(), fn module -> module.init() end)

        max_tick = ECSx.Manager.final_tick(systems())

        {:ok, max_tick, {:continue, :setup}}
      end

      def handle_continue(:start_systems, max_tick) do
        tick_rate = ECSx.tick_rate()
        tick_interval = div(1000, tick_rate)
        :timer.send_interval(tick_interval, :tick)

        {:noreply, {0, max_tick}}
      end

      def handle_info(:tick, {current, max}) do
        Enum.each(systems(), fn system ->
          if rem(current, system.__period__()) == 0 do
            start_time = System.monotonic_time()
            system.run()
            duration = System.monotonic_time() - start_time
            measurements = %{duration: duration}
            metadata = %{system: system}
            :telemetry.execute([:ecsx, :system_run], measurements, metadata)
          end
        end)

        case current + 1 do
          ^max -> {:noreply, {0, max}}
          next -> {:noreply, {next, max}}
        end
      end
    end
  end

  @doc """
  Runs the given code block during startup.

  The code will be run during the Manager's initialization (so pay special attention to the
  position of `ECSx.Manager` in your application's supervision tree). The Component tables will
  be created before `setup` is executed.

  ## Example

  ```
  defmodule YourApp.Manager do
    use ECSx.Manager

    setup do
      for npc <- YourApp.fetch_npc_spawn_info() do
        YourApp.Components.Name.add(npc.id, npc.name)
        YourApp.Components.HitPoints.add(npc.id, npc.hp)
        YourApp.Components.Location.add(npc.id, npc.spawn_location)
      end
    end
  end
  ```

  This setup will spawn each NPC with Components for Name, HitPoints, and Location.
  """
  defmacro setup(block) do
    do_setup(block)
  end

  defp do_setup(do: contents) do
    quote do
      def handle_continue(:setup, state) do
        unquote(contents)
        {:noreply, state, {:continue, :start_systems}}
      end
    end
  end

  @doc false
  def start_link(module) do
    GenServer.start_link(module, [], name: module)
  end

  @doc false
  def final_tick(systems) do
    systems
    |> Enum.map(fn system -> system.__period__() end)
    |> lcm()
  end

  defp lcm(nums) when is_list(nums), do: Enum.reduce(nums, &lcm/2)
  defp lcm(a, b), do: div(abs(a * b), Integer.gcd(a, b))
end
