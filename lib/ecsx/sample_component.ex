defmodule ECSx.SampleComponent do
  use ECSx.Component,
    schema: {:entity_id, :name, :age}
end
