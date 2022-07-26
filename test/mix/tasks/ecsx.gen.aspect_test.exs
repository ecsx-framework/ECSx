Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.AspectTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup do
    create_sample_ecsx_project()
    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "generates aspect module" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Aspect.run(["FooAspect", "id", "value"])

      aspect_file = File.read!("lib/my_app/aspects/foo_aspect.ex")

      assert aspect_file ==
               """
               defmodule MyApp.Aspects.FooAspect do
                 @moduledoc \"\"\"
                 Documentation for FooAspect components.
                 \"\"\"
                 use ECSx.Aspect,
                   schema: {:id, :value}
               end
               """
    end)
  end

  test "injects aspect into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Aspect.run(["FooAspect", "id", "value"])

      manager_file = File.read!("lib/my_app/manager.ex")

      assert manager_file ==
               """
               defmodule MyApp.Manager do
                 @moduledoc \"\"\"
                 ECSx manager.
                 \"\"\"
                 use ECSx.Manager, tick_rate: 20

                 setup do
                   # Load your initial components
                 end

                 # Declare all valid Aspects
                 def aspects do
                   [
                     MyApp.Aspects.FooAspect
                   ]
                 end

                 # Declare all Systems to run
                 def systems do
                   [
                     # MyApp.Systems.SampleSystem
                   ]
                 end
               end
               """
    end)
  end

  test "multiple aspects injected into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Aspect.run(["FooAspect", "id", "value"])
      Mix.Tasks.Ecsx.Gen.Aspect.run(["BarAspect", "id", "value"])
      Mix.Tasks.Ecsx.Gen.Aspect.run(["BazAspect", "id", "value"])

      manager_file = File.read!("lib/my_app/manager.ex")

      assert manager_file ==
               """
               defmodule MyApp.Manager do
                 @moduledoc \"\"\"
                 ECSx manager.
                 \"\"\"
                 use ECSx.Manager, tick_rate: 20

                 setup do
                   # Load your initial components
                 end

                 # Declare all valid Aspects
                 def aspects do
                   [
                     MyApp.Aspects.BazAspect,
                     MyApp.Aspects.BarAspect,
                     MyApp.Aspects.FooAspect
                   ]
                 end

                 # Declare all Systems to run
                 def systems do
                   [
                     # MyApp.Systems.SampleSystem
                   ]
                 end
               end
               """
    end)
  end

  test "fails with invalid arguments" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      # Missing field names
      assert_raise(Mix.Error, fn ->
        Mix.Tasks.Ecsx.Gen.Aspect.run(["FooAspect"])
      end)

      # No arguments
      assert_raise(Mix.Error, fn ->
        Mix.Tasks.Ecsx.Gen.Aspect.run([])
      end)
    end)
  end
end
