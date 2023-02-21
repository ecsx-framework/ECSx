Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.SetupTest do
  use ExUnit.Case

  import ECSx.MixHelper, only: [clean_tmp_dir: 0, sample_mixfile: 0]

  setup do
    File.mkdir!("tmp")
    File.cd!("tmp")
    File.mkdir!("lib")
    File.write!("mix.exs", sample_mixfile())

    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "generates manager and folders" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Setup.run([])

      manager_file = File.read!("lib/my_app/manager.ex")

      assert manager_file ==
               """
               defmodule MyApp.Manager do
                 @moduledoc \"\"\"
                 ECSx manager.
                 \"\"\"
                 use ECSx.Manager

                 setup do
                   # Load your initial components
                 end

                 # Declare all valid Component types
                 def components do
                   [
                     # MyApp.Components.SampleComponent
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

      assert File.dir?("lib/my_app/components")
      assert File.dir?("lib/my_app/systems")
    end)
  end

  test "--no-folders option" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Setup.run(["--no-folders"])

      assert File.exists?("lib/my_app/manager.ex")
      refute File.dir?("lib/my_app/components")
      refute File.dir?("lib/my_app/systems")
    end)
  end
end
