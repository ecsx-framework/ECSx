# coveralls-ignore-start
defmodule ECSx.MockManager do
  use ECSx.Manager

  def systems do
    [
      ECSx.MockSystem1,
      ECSx.MockSystem2
    ]
  end

  def components do
    [
      ECSx.MockComponent1,
      ECSx.MockComponent2
    ]
  end
end

defmodule ECSx.MockComponent1 do
  use ECSx.Component,
    value: :binary
end

defmodule ECSx.MockComponent2 do
  use ECSx.Component,
    value: :binary
end

# coveralls-ignore-stop
