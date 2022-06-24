defmodule <%= inspect app_name %>.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  # Declare all valid Aspects
  def aspects do
    [
      # AspectModuleHere
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      # SystemModuleHere
    ]
  end
end
