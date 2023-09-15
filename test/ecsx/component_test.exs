defmodule ECSx.ComponentTest do
  use ExUnit.Case

  alias ECSx.IntegerComponent
  alias ECSx.StringComponent

  describe "__using__" do
    test "generates functions for a component type" do
      assert :ok == StringComponent.init()

      assert :ok == StringComponent.add(11, "Andy")

      assert "Andy" == StringComponent.get(11)

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
        read_concurrency: :invalid
    end

    test "invalid options are passed" do
      assert_raise ArgumentError, fn ->
        BadReadConcurrency.init()
      end
    end
  end

  describe "#between/2" do
    test "exists for integer component type" do
      assert function_exported?(IntegerComponent, :between, 2)
    end

    test "does not exist for non-numerical component types" do
      refute function_exported?(StringComponent, :between, 2)
    end

    test "arguments must be numerical" do
      assert_raise FunctionClauseError, fn -> IntegerComponent.between(0, "five") end
      assert_raise FunctionClauseError, fn -> IntegerComponent.between(:zero, 5) end
    end
  end

  describe "#at_least/1" do
    test "exists for integer component type" do
      assert function_exported?(IntegerComponent, :at_least, 1)
    end

    test "does not exist for non-numerical component types" do
      refute function_exported?(StringComponent, :at_least, 1)
    end

    test "argument must be numerical" do
      assert_raise FunctionClauseError, fn -> IntegerComponent.at_least("five") end
      assert_raise FunctionClauseError, fn -> IntegerComponent.at_least(:five) end
    end
  end

  describe "#at_most/1" do
    test "exists for integer component type" do
      assert function_exported?(IntegerComponent, :at_most, 1)
    end

    test "does not exist for non-numerical component types" do
      refute function_exported?(StringComponent, :at_most, 1)
    end

    test "argument must be numerical" do
      assert_raise FunctionClauseError, fn -> IntegerComponent.at_most("five") end
      assert_raise FunctionClauseError, fn -> IntegerComponent.at_most(:five) end
    end
  end
end
