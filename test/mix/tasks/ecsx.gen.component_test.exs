Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.ComponentTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup do
    create_sample_ecsx_project()
    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "generates component type module" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent", "binary"])

      component_file = File.read!("lib/my_app/components/foo_component.ex")

      assert component_file ==
               """
               defmodule MyApp.Components.FooComponent do
                 @moduledoc \"\"\"
                 Documentation for FooComponent components.
                 \"\"\"
                 use ECSx.Component,
                   value: :binary
               end
               """
    end)
  end

  test "injects component type into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent", "integer"])

      manager_file = File.read!("lib/my_app/manager.ex")

      assert manager_file ==
               """
               defmodule MyApp.Manager do
                 @moduledoc \"\"\"
                 ECSx manager.
                 \"\"\"
                 use ECSx.Manager

                 def setup do
                   # Seed persistent components only for the first server start
                   # (This will not be run on subsequent app restarts)
                   :ok
                 end

                 def startup do
                   # Load ephemeral components during first server start and again
                   # on every subsequent app restart
                   :ok
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

  test "multiple component types injected into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent", "binary"])
      Mix.Tasks.Ecsx.Gen.Component.run(["BarComponent", "integer"])
      Mix.Tasks.Ecsx.Gen.Component.run(["BazComponent", "float"])

      manager_file = File.read!("lib/my_app/manager.ex")

      assert manager_file ==
               """
               defmodule MyApp.Manager do
                 @moduledoc \"\"\"
                 ECSx manager.
                 \"\"\"
                 use ECSx.Manager

                 def setup do
                   # Seed persistent components only for the first server start
                   # (This will not be run on subsequent app restarts)
                   :ok
                 end

                 def startup do
                   # Load ephemeral components during first server start and again
                   # on every subsequent app restart
                   :ok
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

  test "accepts index option" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent", "binary", "--index"])

      component_file = File.read!("lib/my_app/components/foo_component.ex")

      assert component_file ==
               """
               defmodule MyApp.Components.FooComponent do
                 @moduledoc \"\"\"
                 Documentation for FooComponent components.
                 \"\"\"
                 use ECSx.Component,
                   value: :binary,
                   unique: true,
                   index: true
               end
               """
    end)
  end

  test "fails with invalid arguments" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      # Missing argument
      assert_raise(Mix.Error, fn ->
        Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent"])
      end)

      # No arguments
      assert_raise(Mix.Error, fn ->
        Mix.Tasks.Ecsx.Gen.Component.run([])
      end)

      # Bad value type
      assert_raise(Mix.Error, fn ->
        Mix.Tasks.Ecsx.Gen.Component.run(["FooComponent", "invalid"])
      end)
    end)
  end
end
