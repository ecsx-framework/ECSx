defmodule ECSx.ClientEventsTest do
  use ExUnit.Case

  alias ECSx.ClientEvents

  test "add" do
    entity = "123"
    assert {:noreply, [{entity, "a"}]} == ClientEvents.handle_cast({:add, entity, "a"}, [])

    assert {:noreply, [{entity, "Z"}, {entity, "a"}]} ==
             ClientEvents.handle_cast({:add, entity, "Z"}, [{entity, "a"}])
  end

  test "get_and_clear" do
    state = [{"123", "C"}, {"123", "B"}, {"456", "A"}]

    assert {:reply, Enum.reverse(state), []} ==
             ClientEvents.handle_call(:get_and_clear, self(), state)
  end
end
