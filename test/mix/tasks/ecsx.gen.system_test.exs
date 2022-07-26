Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.SystemTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup do
    create_sample_ecsx_project()
    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "generates system module" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.System.run(["FooSystem"])

      system_file = File.read!("lib/my_app/systems/foo_system.ex")

      assert system_file ==
               """
               defmodule MyApp.Systems.FooSystem do
                 @moduledoc \"\"\"
                 Documentation for FooSystem system.
                 \"\"\"
                 use ECSx.System

                 def run do
                   # System logic
                 end
               end
               """
    end)
  end

  test "injects system into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.System.run(["FooSystem"])

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
                     # MyApp.Aspects.SampleAspect
                   ]
                 end

                 # Declare all Systems to run
                 def systems do
                   [
                     MyApp.Systems.FooSystem
                   ]
                 end
               end
               """
    end)
  end

  test "multiple systems injected into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.System.run(["FooSystem"])
      Mix.Tasks.Ecsx.Gen.System.run(["BarSystem"])

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
                     # MyApp.Aspects.SampleAspect
                   ]
                 end

                 # Declare all Systems to run
                 def systems do
                   [
                     MyApp.Systems.BarSystem,
                     MyApp.Systems.FooSystem
                   ]
                 end
               end
               """
    end)
  end
end
