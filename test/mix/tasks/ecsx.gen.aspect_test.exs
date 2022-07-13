# Get Mix output sent to the current process to avoid polluting tests.
Mix.shell(Mix.Shell.Process)

defmodule Mix.Tasks.Ecsx.Gen.AspectTest do
  use ExUnit.Case

  setup_all do
    File.mkdir!("tmp")

    File.cd!("tmp", fn ->
      File.mkdir!("lib")
      File.mkdir!("lib/ecsx")
      File.mkdir!("lib/ecsx/aspects")

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
      Mix.Tasks.Ecsx.Gen.Aspect.run(["FooAspect", "id", "value"])

      aspect_file = File.read!("lib/ecsx/aspects/foo_aspect.ex")

      assert aspect_file =~ "defmodule ECSx.Aspects.FooAspect do"
      assert aspect_file =~ "@moduledoc \"\"\"\n  Documentation for FooAspect components."
      assert aspect_file =~ "use ECSx.Aspect,"
      assert aspect_file =~ "schema: {:id, :value}"
    end)
  end
end
