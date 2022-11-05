defmodule ECSx.SystemTest do
  use ExUnit.Case

  alias ECSx.TestComponent

  defmodule Incrementer do
    use ECSx.System

    @impl ECSx.System
    def run do
      for {id, value} <- TestComponent.get_all() do
        TestComponent.remove(id)
        TestComponent.add(id, value + 1)
      end
    end
  end

  setup do
    TestComponent.init()
    TestComponent.add(1, 1)
    TestComponent.add(100, 100)
  end

  describe "Incrementer system" do
    test "#run/0" do
      Incrementer.run()

      assert :ets.lookup(TestComponent, 1) == [{1, 2}]
      assert :ets.lookup(TestComponent, 100) == [{100, 101}]

      Incrementer.run()

      assert :ets.lookup(TestComponent, 1) == [{1, 3}]
      assert :ets.lookup(TestComponent, 100) == [{100, 102}]
    end
  end
end
