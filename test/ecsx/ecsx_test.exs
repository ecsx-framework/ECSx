defmodule ECSxTest do
  use ExUnit.Case, async: false

  describe "manager/0" do
    test "standard module" do
      Application.put_env(:ecsx, :manager, FooApp.BarManager)

      assert ECSx.manager() == FooApp.BarManager
    end

    test "module with path" do
      Application.put_env(:ecsx, :manager, {FooApp.BarManager, path: "foo/bar/baz.ex"})

      assert ECSx.manager() == FooApp.BarManager
    end

    test "unconfigured" do
      Application.delete_env(:ecsx, :manager)

      assert ECSx.manager() == nil
    end
  end

  describe "manager_path/0" do
    test "standard module" do
      Application.put_env(:ecsx, :manager, FooApp.BarManager)

      assert ECSx.manager_path() == "lib/foo_app/bar_manager.ex"
    end

    test "module with path" do
      Application.put_env(:ecsx, :manager, {FooApp.BarManager, path: "foo/bar/baz.ex"})

      assert ECSx.manager_path() == "foo/bar/baz.ex"
    end

    test "unconfigured" do
      Application.delete_env(:ecsx, :manager)

      assert ECSx.manager_path() == nil
    end
  end

  describe "tick_rate/0" do
    test "fetches from app config" do
      Application.put_env(:ecsx, :tick_rate, 101)

      assert ECSx.tick_rate() == 101
    end

    test "defaults to 20 when unconfigured" do
      Application.delete_env(:ecsx, :tick_rate)

      assert ECSx.tick_rate() == 20
    end
  end
end
