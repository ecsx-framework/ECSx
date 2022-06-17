defmodule ECSx.ComponentTest do
  use ExUnit.Case

  import ECSx.Factory

  alias ECSx.Component
  alias ECSx.Test.Couple
  alias ECSx.Test.Triple

  describe "#init/1" do
    test "fails with non-module argument" do
      assert_raise ECSx.InvalidAspectModule, fn ->
        Component.init(:foo)
      end
    end

    test "fails if given module is not a component aspect" do
      assert_raise ECSx.InvalidAspectModule, fn ->
        Component.init(Enum)
      end
    end
  end

  describe "#add/2" do
    test "creates new components" do
      Component.init(Couple)
      Component.add(Couple, id: 1, foo: "Andy")

      assert [{1, "Andy"}] == :ets.lookup(Couple, 1)
    end
  end

  describe "#get/3" do
    test "returns valid component" do
      Component.init(Triple)
      component = insert_new(Triple)

      assert Component.get(Triple, component.id) == %{
               id: component.id,
               foo: component.foo,
               bar: component.bar
             }

      assert Component.get(Triple, component.id, select: [field: :foo]) == component.foo

      assert Component.get(Triple, component.id, select: [all: :tuple]) ==
               {component.id, component.foo, component.bar}

      assert Component.get(Triple, component.id, select: [fields: [:id, :foo]]) ==
               {component.id, component.foo}
    end
  end

  describe "#get_all/2" do
    test "OK" do
      Component.init(Couple)
      components = for _ <- 1..3, do: insert_new(Couple)

      assert Couple
             |> Component.get_all()
             |> Enum.sort_by(& &1.id) == Enum.sort_by(components, & &1.id)
    end
  end

  describe "#remove/2" do
    test "OK" do
      Component.init(Couple)
      component = insert_new(Couple)

      Component.remove(Couple, component.id)

      refute :ets.member(Couple, component.id)
    end
  end

  describe "#has_component?/2" do
    test "OK" do
      Component.init(Couple)
      component = insert_new(Couple)

      assert Component.has_component?(Couple, component.id)
    end
  end
end
