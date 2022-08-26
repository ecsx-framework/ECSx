defmodule ECSx.System do
  @moduledoc """
  A fragment of game logic which reads and updates Components.

  Every System must implement a `run` function.

  By default, the System will run every game tick.  To use a longer period between runs,
  you can pass the option `:period`.  For example, to set a System to run every 5 ticks:

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

  @doc """
  Invoked to run System logic.

  This function will be called every `T` game ticks, where `T` is the value of
  the System's `:period` option (defaults to 1).

  Note:  A crash inside this function will restart the entire app!
  """
  @callback run() :: :ok
end
