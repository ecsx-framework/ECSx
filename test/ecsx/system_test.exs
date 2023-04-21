defmodule ECSx.SystemTest do
  use ExUnit.Case

  alias ECSx.IntegerComponent

  defmodule Incrementer do
    @behaviour ECSx.System

    @impl ECSx.System
    def run do
      for {id, value} <- IntegerComponent.get_all() do
        IntegerComponent.remove(id)
        IntegerComponent.add(id, value + 1)
      end
    end
  end

  setup do
    IntegerComponent.init()
    IntegerComponent.add(1, 1)
    IntegerComponent.add(100, 100)
  end

  describe "Incrementer system" do
    test "#run/0" do
      Incrementer.run()

      assert :ets.lookup(IntegerComponent, 1) == [{1, 2}]
      assert :ets.lookup(IntegerComponent, 100) == [{100, 101}]

      Incrementer.run()

      assert :ets.lookup(IntegerComponent, 1) == [{1, 3}]
      assert :ets.lookup(IntegerComponent, 100) == [{100, 102}]
    end
  end
end
