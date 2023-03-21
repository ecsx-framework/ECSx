defmodule ECSx.ConstantTest do
  use ExUnit.Case

  defmodule FooConstant do
    use ECSx.Constant,
      values: %{
        foo: %{
          bar: "baz"
        },
        uno: "dos"
      }
  end

  describe "get/1" do
    test "single key" do
      assert FooConstant.get(:uno) == "dos"
    end

    test "nested keys" do
      assert FooConstant.get([:foo, :bar]) == "baz"
    end

    test "bad single key" do
      assert FooConstant.get(:invalid) == nil
    end

    test "bad nested keys" do
      assert FooConstant.get([:these, :are, :bad, :keys]) == nil
    end
  end
end
