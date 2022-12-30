defmodule ECSx.ComponentTest do
  use ExUnit.Case

  alias ECSx.TestComponent

  describe "__using__" do
    test "generates functions for a component type" do
      assert :ok == TestComponent.init()

      assert :ok == TestComponent.add(11, "Andy")

      assert "Andy" == TestComponent.get_one(11)

      for {id, foo} <- [{1, "A"}, {2, "B"}, {3, "C"}],
          do: TestComponent.add(id, foo)

      assert :ok == TestComponent.remove(3)

      refute TestComponent.exists?(3)

      assert TestComponent.exists?(1)
      assert TestComponent.exists?(2)
      assert TestComponent.exists?(11)

      all_components = TestComponent.get_all()

      assert Enum.sort(all_components) == [
               {1, "A"},
               {2, "B"},
               {11, "Andy"}
             ]
    end

    defmodule BadReadConcurrency do
      use ECSx.Component,
        unique: true,
        read_concurrency: :invalid
    end

    defmodule BadUniqueFlag do
      use ECSx.Component,
        unique: :invalid
    end

    test "invalid options are passed" do
      assert_raise ArgumentError, fn ->
        BadReadConcurrency.init()
      end

      # assert_raise ArgumentError, fn ->
      #   BadUniqueFlag.init()
      # end
    end
  end
end
