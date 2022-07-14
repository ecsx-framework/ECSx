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

  def create_sample_ecsx_project do
    File.rm_rf!("tmp")
    File.mkdir!("tmp")
    File.cd!("tmp")

    File.mkdir!("lib")
    File.mkdir!("lib/my_app")
    File.mkdir!("lib/my_app/aspects")
    File.write!("mix.exs", @sample_mixfile)

    source = Application.app_dir(:ecsx, "/priv/templates/manager.ex")
    content = EEx.eval_file(source, app_name: MyApp)
    File.write!("lib/my_app/manager.ex", content)
  end

  def clean_tmp_dir do
    File.cd!("..")
    File.rm_rf!("tmp")
  end
end
