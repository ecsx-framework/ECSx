# Get Mix output sent to the current process to avoid polluting tests.
Mix.shell(Mix.Shell.Process)

defmodule Mix.Tasks.Ecsx.Gen.SystemTest do
  use ExUnit.Case

  setup_all do
    File.mkdir!("tmp")

    File.cd!("tmp", fn ->
      File.mkdir!("lib")
      File.mkdir!("lib/ecsx")
      File.mkdir!("lib/ecsx/systems")

      source = Application.app_dir(:ecsx, "/priv/templates/manager.ex")
      content = EEx.eval_file(source, app_name: MyApp)
      File.write!("lib/ecsx/manager.ex", content)
    end)

    on_exit(fn ->
      File.rm_rf!("tmp")
    end)

    :ok
  end

  test "generates aspect in existing project" do
    File.cd!("tmp", fn ->
      Mix.Tasks.Ecsx.Gen.System.run(["FooSystem"])

      system_file = File.read!("lib/ecsx/systems/foo_system.ex")

      assert system_file =~ "defmodule ECSx.Systems.FooSystem do"
      assert system_file =~ "@moduledoc \"\"\"\n  Documentation for FooSystem system."
      assert system_file =~ "use ECSx.System"
      assert system_file =~ "def run do"
    end)
  end
end
