Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.SystemTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup_all do
    create_sample_ecsx_project()

    on_exit(&clean_tmp_dir/0)

    :ok
  end

  test "generates aspect in existing project" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.System.run(["FooSystem"])

      system_file = File.read!("lib/my_app/systems/foo_system.ex")

      assert system_file =~ "defmodule MyApp.Systems.FooSystem do"
      assert system_file =~ "@moduledoc \"\"\"\n  Documentation for FooSystem system."
      assert system_file =~ "use ECSx.System"
      assert system_file =~ "def run do"
    end)
  end
end
