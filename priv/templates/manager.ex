defmodule <%= inspect app_name %>.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager, tick_rate: 20

  setup do
    # Load your initial components
  end

  # Declare all valid Aspects
  def aspects do
    [
      <%= inspect app_name %>.Aspects.SampleAspect
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      <%= inspect app_name %>.Systems.SampleSystem
    ]
  end
end
