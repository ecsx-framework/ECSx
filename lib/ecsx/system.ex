defmodule ECSx.System do
  @moduledoc """
  A fragment of game logic which reads and updates Components.

  Every system must implement a `run` function.

  By default the system will run every game tick.  To use a longer period between runs,
  you can pass the option `:period`.  For example, to set a system to run every 5 ticks:

      use ECSx.System,
        period: 5

  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.System

      @period opts[:period] || 1

      def __period__, do: @period
    end
  end

  @callback run() :: :ok
end
