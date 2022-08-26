defmodule Mix.Tasks.Ecsx.Gen.Aspect do
  @shortdoc "Generates a new ECSx Aspect"

  @moduledoc """
  Generates a new Aspect for an ECSx application.

      $ mix ecsx.gen.aspect Color entity_id hue saturation lightness

  The first argument is the name of the Aspect module, followed by the data fields
  which will make up each Component.
  """

  use Mix.Task
  import Mix.Tasks.ECSx.Helpers, only: [otp_app: 0, root_module: 0]

  @doc false
  def run([]) do
    "Invalid arguments."
    |> message_with_help()
    |> Mix.raise()
  end

  def run([_aspect_name]) do
    "Invalid arguments - must provide at least one field name."
    |> message_with_help()
    |> Mix.raise()
  end

  def run([aspect_name | _] = args) do
    create_aspect_file(args)
    inject_aspect_module_into_manager(aspect_name)
  end

  defp message_with_help(message) do
    """
    #{message}

    mix ecsx.gen.aspect expects an aspect module name (in PascalCase), followed by
    the field names (in snake_case).

    For example:

        mix ecsx.gen.aspect MyAspect entity_id value

    """
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
    {before_aspects, after_aspects, list} = parse_manager(manager_path)

    new_list =
      aspect_name
      |> add_aspect_to_list(list)
      |> ensure_list_format()

    new_contents =
      [before_aspects, "def aspects do\n    ", new_list, "\n  end", after_aspects]
      |> IO.iodata_to_binary()
      |> Code.format_string!()

    Mix.shell().info([:green, "* injecting ", :reset, manager_path])
    File.write!(manager_path, [new_contents, "\n"])
  end

  defp parse_manager(path) do
    file = File.read!(path)
    [top, rest] = String.split(file, "def aspects do", parts: 2)
    [list, bottom] = String.split(rest, "end", parts: 2)

    {top, bottom, list}
  end

  defp add_aspect_to_list(aspect_name, list_as_string) do
    {result, _binding} = Code.eval_string(list_as_string)

    aspect_name
    |> full_aspect_module()
    |> then(&[&1 | result])
    |> inspect()
  end

  defp full_aspect_module(aspect_name) do
    Module.concat([root_module(), "Aspects", aspect_name])
  end

  # Adds a newline to ensure the list is formatted with one aspect per line
  defp ensure_list_format(list_as_string) do
    ["[" | rest] = String.graphemes(list_as_string)

    ["[\n" | rest]
  end
end
