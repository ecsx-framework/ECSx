defmodule <%= app_name %>.Systems.<%= system_name %> do
  @moduledoc """
  Documentation for <%= system_name %> system.
  """
  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic
    :ok
  end
end
