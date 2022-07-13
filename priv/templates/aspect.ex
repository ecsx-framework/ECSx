defmodule <%= app_name %>.Aspects.<%= aspect_name %> do
  @moduledoc """
  Documentation for <%= aspect_name %> components.
  """
  use ECSx.Aspect,
    schema: {<%= fields %>}
end
