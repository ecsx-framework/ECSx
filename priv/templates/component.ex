defmodule <%= app_name %>.Components.<%= component_type %> do
  @moduledoc """
  Documentation for <%= component_type %> components.
  """
  use ECSx.Component,
    value: <%= inspect(value) %>,
    unique: <%= unique %>
end
