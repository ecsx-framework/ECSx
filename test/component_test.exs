defmodule ECSx.ComponentTest do
  use ExUnit.Case

  import ECSx.Factory

  alias ECSx.KVTestComponent

  describe "__using__" do
    test "generates __init__/0" do
      assert KVTestComponent.__init__()
    end

    test "generates add/2" do
      initialize_table(KVTestComponent)
      KVTestComponent.add(id: 1, name: "Andy")

      assert [{1, "Andy"}] == :ets.lookup(KVTestComponent, 1)
    end

    test "generates remove/1" do
      initialize_table(KVTestComponent)
      component = insert_new(KVTestComponent)

      KVTestComponent.remove(component.id)

      refute KVTestComponent.has_component?(component.id)
    end

    test "generates has_component?/1" do
      initialize_table(KVTestComponent)
      component = insert_new(KVTestComponent)

      assert KVTestComponent.has_component?(component.id)
    end
  end
end
