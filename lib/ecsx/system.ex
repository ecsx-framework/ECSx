defmodule ECSx.System do
  @moduledoc """
  A fragment of game logic which reads and updates Components.

  Each System must implement a `run/0` function, which will be called once per game tick.
  """

  defmacro __using__ do
    quote do
      @behaviour ECSx.System
    end
  end

  @doc """
  Invoked to run System logic.

  This function will be called every game tick.

  Note:  A crash inside this function will restart the entire app!
  """
  @callback run() :: :ok
end
