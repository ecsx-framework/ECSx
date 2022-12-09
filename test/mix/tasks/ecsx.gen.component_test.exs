Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.ComponentTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup do
    create_sample_ecsx_project()
    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "generates component module" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent"])

      component_file = File.read!("lib/my_app/components/foo_component.ex")

      assert component_file ==
               """
               defmodule MyApp.Components.FooComponent do
                 @moduledoc \"\"\"
                 Documentation for FooComponent components.
                 \"\"\"
                 use ECSx.Component,
                   unique: true
               end
               """
    end)
  end

  test "injects component into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent"])

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

                 # Declare all valid Component types
                 def components do
                   [
                     MyApp.Components.FooComponent
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

  test "multiple components injected into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent"])
      Mix.Tasks.Ecsx.Gen.Component.run(["BarComponent"])
      Mix.Tasks.Ecsx.Gen.Component.run(["BazComponent"])

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

                 # Declare all valid Component types
                 def components do
                   [
                     MyApp.Components.BazComponent,
                     MyApp.Components.BarComponent,
                     MyApp.Components.FooComponent
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
      # assert_raise(Mix.Error, fn ->
      #   Mix.Tasks.Ecsx.Gen.Component.run(["FooAspect"])
      # end)

      # No arguments
      assert_raise(Mix.Error, fn ->
        Mix.Tasks.Ecsx.Gen.Component.run([])
      end)
    end)
  end
end
