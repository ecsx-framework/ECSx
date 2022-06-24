defmodule Mix.Tasks.Ecsx.Setup do
  @shortdoc "Generates manager process for ECSx"

  @moduledoc """
  Generates the manager process which runs an ECSx application.

      $ mix ecsx.setup

  """

  use Mix.Task

  @doc false
  def run(_args) do
    otp_app = otp_app()
    target = "lib/#{otp_app}/manager.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/manager.ex")
    binding = [app_name: app_module(otp_app)]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end

  defp otp_app do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
  end

  defp app_module(otp_app) do
    otp_app
    |> to_string()
    |> Macro.camelize()
    |> List.wrap()
    |> Module.concat()
  end
end
