defmodule Mix.Tasks.ECSx.Helpers do
  @moduledoc false

  def otp_app do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
  end

  def root_module do
    config = Mix.Project.config()

    case Keyword.get(config, :name) do
      nil -> config |> Keyword.fetch!(:app) |> root_module()
      name -> name
    end
  end

  defp root_module(otp_app) do
    otp_app
    |> to_string()
    |> Macro.camelize()
    |> List.wrap()
    |> Module.concat()
    |> inspect()
  end

  def write_file(contents, path), do: File.write!(path, contents)
end
