# Get Mix output sent to the current process to avoid polluting tests.
Mix.shell(Mix.Shell.Process)

defmodule ECSx.MixHelper do
  @moduledoc """
  Conveniently creates a new ECSx project for testing generators.
  """

  @sample_mixfile """
  defmodule MyApp.MixProject do
    use Mix.Project

    def project do
      [
        app: :my_app
      ]
    end
  end
  """

  @components_list """
  [
    # MyApp.Components.SampleComponent
  ]
  """

  @systems_list """
  [
    # MyApp.Systems.SampleSystem
  ]
  """

  def create_sample_ecsx_project do
    File.rm_rf!("tmp")
    File.mkdir!("tmp")
    File.cd!("tmp")

    File.mkdir!("lib")
    File.mkdir!("lib/my_app")
    File.mkdir!("lib/my_app/components")
    Application.put_env(:ecsx, :manager, MyApp.Manager)
    File.write!("mix.exs", @sample_mixfile)

    source = Application.app_dir(:ecsx, "/priv/templates/manager.ex")

    content =
      EEx.eval_file(source,
        app_name: "MyApp",
        components_list: @components_list,
        systems_list: @systems_list
      )

    File.write!("lib/my_app/manager.ex", content)
  end

  def clean_tmp_dir do
    File.cd!("..")
    File.rm_rf!("tmp")
    Application.delete_env(:ecsx, :manager)
  end

  def sample_mixfile, do: @sample_mixfile
end
