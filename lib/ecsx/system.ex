defmodule ECSx.System do
  @moduledoc """
  A fragment of game logic which reads and updates Components.

  Each System must implement a `run/0` function, which will be called once per game tick.

      defmodule MyApp.FooSystem do
        @behaviour ECSx.System

        @impl ECSx.System
        def run do
          # System logic
          :ok
        end
      end

  """

  @doc """
  Invoked to run System logic.

  This function will be called every game tick.

  Note:  A crash inside this function will restart the entire app!
  """
  @callback run() :: any()
end
