Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.AspectTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup_all do
    create_sample_ecsx_project()

    on_exit(&clean_tmp_dir/0)

    :ok
  end

  test "generates aspect in existing project" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Aspect.run(["FooAspect", "id", "value"])

      aspect_file = File.read!("lib/my_app/aspects/foo_aspect.ex")

      assert aspect_file =~ "defmodule MyApp.Aspects.FooAspect do"
      assert aspect_file =~ "@moduledoc \"\"\"\n  Documentation for FooAspect components."
      assert aspect_file =~ "use ECSx.Aspect,"
      assert aspect_file =~ "schema: {:id, :value}"
    end)
  end
end
