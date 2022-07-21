Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.SetupTest do
  use ExUnit.Case

  import ECSx.MixHelper, only: [clean_tmp_dir: 0]

  setup_all do
    File.mkdir!("tmp")
    File.cd!("tmp")
    File.mkdir!("lib")

    on_exit(&clean_tmp_dir/0)

    :ok
  end

  test "generates manager and folders" do
    Mix.Tasks.Ecsx.Setup.run([])

    manager_file = File.read!("lib/ecsx/manager.ex")

    assert manager_file =~ "defmodule ECSx.Manager do"
    assert manager_file =~ "@moduledoc \"\"\"\n  ECSx manager."
    assert manager_file =~ "use ECSx.Manager, tick_rate: 20"
    assert manager_file =~ "setup do"
    assert manager_file =~ "def aspects do\n    [\n      ECSx.Aspects.SampleAspect"
    assert manager_file =~ "def systems do\n    [\n      ECSx.Systems.SampleSystem"

    assert File.dir?("lib/ecsx/aspects")
    assert File.dir?("lib/ecsx/systems")
  end

  test "--no-folders option" do
    Mix.Tasks.Ecsx.Setup.run(["--no-folders"])

    assert File.exists?("lib/ecsx/manager.ex")
    refute File.dir?("lib/ecsx/aspects")
    refute File.dir?("lib/ecsx/systems")
  end
end
