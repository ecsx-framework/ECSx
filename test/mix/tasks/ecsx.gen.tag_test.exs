Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.TagTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup do
    create_sample_ecsx_project()
    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "generates tag module" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Tag.run(["FooTag"])

      component_file = File.read!("lib/my_app/components/foo_tag.ex")

      assert component_file ==
               """
               defmodule MyApp.Components.FooTag do
                 @moduledoc \"\"\"
                 Documentation for FooTag components.
                 \"\"\"
                 use ECSx.Tag
               end
               """
    end)
  end

  test "injects component type into manager" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Tag.run(["FooTag"])

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
                     MyApp.Components.FooTag
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
      Mix.Tasks.Ecsx.Gen.Tag.run(["FooTag"])
      Mix.Tasks.Ecsx.Gen.Tag.run(["BarTag"])
      Mix.Tasks.Ecsx.Gen.Tag.run(["BazTag"])

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
                     MyApp.Components.BazTag,
                     MyApp.Components.BarTag,
                     MyApp.Components.FooTag
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
      # No arguments
      assert_raise(Mix.Error, fn ->
        Mix.Tasks.Ecsx.Gen.Tag.run([])
      end)
    end)
  end
end
