defmodule ECSx.ManagerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

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
      {result, log} =
        with_log(fn ->
          AppToSetup.handle_continue(:start_systems, "state")
        end)

      assert result == {:noreply, "state"}
      assert log =~ "[info] Retrieved Components"
      assert_receive :startup
    end
  end

  describe "tick/0" do
    test "manual tick fails without proper env" do
      Application.put_env(:ecsx, :tick_rate, 101)

      AppToSetup.handle_continue(:start_systems, "state")

      assert AppToSetup.tick() == {:error, :requires_manual_click_rate}
    end

    test "manual tick works" do
      Application.put_env(:ecsx, :tick_rate, :manual)

      AppToSetup.handle_continue(:start_systems, "state")

      assert AppToSetup.tick() == :tick
      assert_receive :tick
    end
  end
end
