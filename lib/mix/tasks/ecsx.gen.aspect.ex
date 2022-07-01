defmodule Mix.Tasks.Ecsx.Gen.Aspect do
  @shortdoc "Generates a new ECSx Aspect"

  @moduledoc """
  Generates a new Aspect for an ECSx application.

      $ mix ecsx.gen.aspect

  """

  use Mix.Task

  @doc false
  def run([aspect_name | _] = args) do
    create_aspect_file(args)
    inject_aspect_module_into_manager(aspect_name)
  end

  defp create_aspect_file([aspect_name | fields]) do
    formatted_fields = Enum.map_join(fields, ", ", fn field -> ":#{field}" end)
    filename = Macro.underscore(aspect_name)
    target = "lib/#{otp_app()}/aspects/#{filename}.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/aspect.ex")
    binding = [app_name: root_module(), fields: formatted_fields, aspect_name: aspect_name]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end

  defp inject_aspect_module_into_manager(aspect_name) do
    manager_path = "lib/#{otp_app()}/manager.ex"
    pattern = "def aspects do\n    [\n"
    Mix.shell().info([:green, "* injecting ", :reset, manager_path])

    manager_path
    |> File.read!()
    |> String.split(pattern, parts: 2)
    |> Enum.intersperse(pattern <> "      #{inspect(root_module())}.Aspects.#{aspect_name},\n")
    |> write_file(manager_path)
  end

  defp otp_app do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
  end

  defp root_module do
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
  end

  defp write_file(contents, path), do: File.write!(path, contents)
end
