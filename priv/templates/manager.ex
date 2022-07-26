defmodule <%= app_name %>.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager, tick_rate: 20

  setup do
    # Load your initial components
  end

  # Declare all valid Aspects
  def aspects do
    <%= aspects_list %>
  end

  # Declare all Systems to run
  def systems do
    <%= systems_list %>
  end
end
