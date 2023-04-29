defmodule ECSx.PersistenceTest do
  use ExUnit.Case, async: false

  describe "#persist_components/1" do
    test "persists all components tagged with persist: true" do
      Application.put_env(:ecsx, :manager, ECSx.MockManager)
      ECSx.MockComponent1.init()
      ECSx.MockComponent2.init()
      :ets.insert(ECSx.MockComponent1, {123, "foo", true})
      :ets.insert(ECSx.MockComponent1, {234, "bar", false})
      :ets.insert(ECSx.MockComponent2, {345, "baz", true})
      :ets.insert(ECSx.MockComponent2, {456, "foobaz", false})
      ECSx.Persistence.persist_components(target: self())

      assert_receive {:persist_components,
                      [
                        {ECSx.MockComponent1, [{123, "foo", true}]},
                        {ECSx.MockComponent2, [{345, "baz", true}]}
                      ]}
    end
  end

  describe "#retrieve_components/1" do
    Application.put_env(:ecsx, :manager, ECSx.MockManager)
    ECSx.MockComponent1.init()
    ECSx.MockComponent2.init()

    ECSx.Persistence.retrieve_components(
      test_components: [
        {ECSx.MockComponent1, [{123, "foo", true}]},
        {ECSx.MockComponent2, [{345, "baz", true}]}
      ]
    )

    assert ECSx.MockComponent1.get_all() == [{123, "foo"}]
    assert ECSx.MockComponent2.get_all() == [{345, "baz"}]
  end
end
