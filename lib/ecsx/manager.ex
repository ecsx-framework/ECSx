defmodule ECSx.Manager do
  @moduledoc """
  The Manager for your ECSx application.

  In an ECSx application, the Manager is responsible for:

    * starting up ETS tables for each Aspect, where the Components will be stored
    * keeping track of the Systems to run, and their run order
    * configuring the tick rate for the application
    * running the Systems every tick
    * validating and writing updates from the player clients

  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use GenServer

      import ECSx.Manager

      @tick_rate opts[:tick_rate] || 20

      def start_link(_), do: ECSx.Manager.start_link(__MODULE__)

      def init(_) do
        Enum.each(aspects(), fn module -> module.init() end)

        max_tick = ECSx.Manager.final_tick(systems())

        {:ok, max_tick, {:continue, :setup}}
      end

      def handle_continue(:start_systems, max_tick) do
        tick_interval = div(1000, @tick_rate)
        :timer.send_interval(tick_interval, :tick)

        {:noreply, {0, max_tick}}
      end

      def handle_info(:tick, {current, max}) do
        Enum.each(systems(), fn system ->
          if rem(current, system.__period__()) == 0 do
            system.run()
          end
        end)

        case current + 1 do
          ^max -> {:noreply, {0, max}}
          next -> {:noreply, {next, max}}
        end
      end
    end
  end

  defmacro setup(do: contents) do
    quote do
      def handle_continue(:setup, state) do
        unquote(contents)
        {:noreply, state, {:continue, :start_systems}}
      end
    end
  end

  def start_link(module) do
    GenServer.start_link(module, [], name: module)
  end

  def final_tick(systems) do
    systems
    |> Enum.map(fn system -> system.__period__() end)
    |> lcm()
  end

  defp lcm(nums) when is_list(nums), do: Enum.reduce(nums, &lcm/2)
  defp lcm(a, b), do: div(abs(a * b), Integer.gcd(a, b))
end
