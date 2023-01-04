defmodule ECSx.StringComponent do
  use ECSx.Component,
    value: :binary,
    unique: true
end
