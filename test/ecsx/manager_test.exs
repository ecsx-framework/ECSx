defmodule ECSx.ManagerTest do
  use ExUnit.Case

  defmodule AppToSetup do
    use ECSx.Manager

    ECSx.Manager.setup do
      :ets.insert(:test, {123, "foo"})
      :ets.insert(:test, {456, "bar"})
    end

    def components, do: []
    def systems, do: []
  end

  describe "setup/1" do
    test "creates handle_continue/2 which runs code block" do
      :ets.new(:test, [:named_table])

      assert AppToSetup.handle_continue(:setup, "state") ==
               {:noreply, "state", {:continue, :start_systems}}

      assert :test
             |> :ets.tab2list()
             |> Enum.sort() == [{123, "foo"}, {456, "bar"}]
    end
  end
end
