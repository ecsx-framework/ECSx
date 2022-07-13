# Get Mix output sent to the current process to avoid polluting tests.
Mix.shell(Mix.Shell.Process)

defmodule Mix.Tasks.Ecsx.SetupTest do
  use ExUnit.Case

  setup_all do
    File.mkdir!("tmp")

    File.cd!("tmp", fn ->
      File.mkdir!("lib")
    end)

    on_exit(fn ->
      File.rm_rf!("tmp")
    end)

    :ok
  end

  test "generates manager and samples" do
    File.cd!("tmp", fn ->
      Mix.Tasks.Ecsx.Setup.run([])

      manager_file = File.read!("lib/ecsx/manager.ex")
      aspect_file = File.read!("lib/ecsx/aspects/sample_aspect.ex")
      system_file = File.read!("lib/ecsx/systems/sample_system.ex")

      assert manager_file =~ "defmodule ECSx.Manager do"
      assert manager_file =~ "@moduledoc \"\"\"\n  ECSx manager."
      assert manager_file =~ "use ECSx.Manager, tick_rate: 20"
      assert manager_file =~ "setup do"
      assert manager_file =~ "def aspects do\n    [\n      ECSx.Aspects.SampleAspect"
      assert manager_file =~ "def systems do\n    [\n      ECSx.Systems.SampleSystem"

      assert aspect_file =~ "defmodule ECSx.Aspects.SampleAspect do"
      assert aspect_file =~ "@moduledoc \"\"\"\n  Documentation for SampleAspect components."
      assert aspect_file =~ "use ECSx.Aspect,"
      assert aspect_file =~ "schema: {:entity_id, :value}"

      assert system_file =~ "defmodule ECSx.Systems.SampleSystem do"
      assert system_file =~ "@moduledoc \"\"\"\n  Documentation for SampleSystem system."
      assert system_file =~ "use ECSx.System"
      assert system_file =~ "def run do"
    end)
  end
end
