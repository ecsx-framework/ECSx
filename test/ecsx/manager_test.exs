defmodule ECSx.ManagerTest do
  use ExUnit.Case

  defmodule AppToSetup do
    use ECSx.Manager

    def setup do
      send(self(), :setup)
      :ok
    end

    def startup do
      send(self(), :startup)
      :ok
    end

    def components, do: []
    def systems, do: []
  end

  describe "setup/1" do
    test "handle_continue/2 runs startup code block" do
      assert AppToSetup.handle_continue(:start_systems, "state") ==
               {:noreply, "state"}

      assert_receive :startup
    end
  end
end
