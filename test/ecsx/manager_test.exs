defmodule ECSx.ManagerTest do
  use ExUnit.Case

  defmodule AppToSetup do
    use ECSx.Manager

    ECSx.Manager.setup do
      :ets.insert(:test, {123, "foo"})
    end

    def aspects, do: []
    def systems, do: []
  end

  describe "setup/1" do
    test "creates handle_continue/2 which runs code block" do
      :ets.new(:test, [:named_table])

      assert AppToSetup.handle_continue(:setup, "state") ==
               {:noreply, "state", {:continue, :start_systems}}

      assert :ets.lookup(:test, 123) == [{123, "foo"}]
    end
  end
end
