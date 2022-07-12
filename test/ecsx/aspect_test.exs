defmodule ECSx.AspectTest do
  use ExUnit.Case

  alias ECSx.Test.Couple

  describe "__using__" do
    test "generates functions for an aspect" do
      assert :ok == Couple.init()

      assert :ok == Couple.add_component(id: 11, foo: "Andy")

      assert %{id: 11, foo: "Andy"} == Couple.get_component(11)

      for {id, foo} <- [{1, "A"}, {2, "B"}, {3, "C"}],
          do: Couple.add_component(id: id, foo: foo)

      assert :ok == Couple.remove_component(3)

      refute Couple.has_component?(3)

      assert Couple.has_component?(1)
      assert Couple.has_component?(2)
      assert Couple.has_component?(11)

      all_couples = Couple.get_all()

      assert Enum.sort_by(all_couples, & &1.id) == [
               %{id: 1, foo: "A"},
               %{id: 2, foo: "B"},
               %{id: 11, foo: "Andy"}
             ]
    end

    defmodule BadReadConcurrency do
      use ECSx.Aspect,
        schema: {:id, :value},
        read_concurrency: :invalid
    end

    defmodule BadTableType do
      use ECSx.Aspect,
        schema: {:id, :value},
        table_type: :invalid
    end

    test "invalid options are passed" do
      assert_raise ArgumentError, fn ->
        BadReadConcurrency.init()
      end

      assert_raise ArgumentError, fn ->
        BadTableType.init()
      end
    end
  end
end
