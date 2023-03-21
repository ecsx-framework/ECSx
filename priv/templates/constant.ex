defmodule <%= app_name %>.Constants.<%= constant %> do
  @moduledoc """
  Documentation for <%= constant %>.
  """
  use ECSx.Constant,
    values: %{<%= values %>}
end
