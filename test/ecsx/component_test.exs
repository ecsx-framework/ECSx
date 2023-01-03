defmodule ECSx.ComponentTest do
  use ExUnit.Case

  alias ECSx.StringComponent

  describe "__using__" do
    test "generates functions for a component type" do
      assert :ok == StringComponent.init()

      assert :ok == StringComponent.add(11, "Andy")

      assert "Andy" == StringComponent.get_one(11)

      for {id, foo} <- [{1, "A"}, {2, "B"}, {3, "C"}],
          do: StringComponent.add(id, foo)

      assert :ok == StringComponent.remove(3)

      refute StringComponent.exists?(3)

      assert StringComponent.exists?(1)
      assert StringComponent.exists?(2)
      assert StringComponent.exists?(11)

      all_components = StringComponent.get_all()

      assert Enum.sort(all_components) == [
               {1, "A"},
               {2, "B"},
               {11, "Andy"}
             ]
    end

    defmodule BadReadConcurrency do
      use ECSx.Component,
        value: :integer,
        unique: true,
        read_concurrency: :invalid
    end

    test "invalid options are passed" do
      assert_raise ArgumentError, fn ->
        BadReadConcurrency.init()
      end
    end
  end
end
