defmodule Mix.Tasks.Ecsx.Gen.Tag do
  @shortdoc "Generates a new ECSx Tag - a Component type which doesn't store any value"

  @moduledoc """
  Generates a new Component type for an ECSx application.

      $ mix ecsx.gen.tag Attackable

  The single argument is the name of the component.
  """

  use Mix.Task
  import Mix.Tasks.ECSx.Helpers, only: [otp_app: 0, root_module: 0]

  @doc false
  def run([]) do
    "Invalid arguments."
    |> message_with_help()
    |> Mix.raise()
  end

  def run([tag_name | _]) do
    create_component_file(tag_name)
    inject_component_module_into_manager(tag_name)
  end

  defp message_with_help(message) do
    """
    #{message}

    mix ecsx.gen.tag expects a tag module name (in PascalCase).

    For example:

        mix ecsx.gen.tag MyTag

    """
  end

  defp create_component_file(tag_name) do
    filename = Macro.underscore(tag_name)
    target = "lib/#{otp_app()}/components/#{filename}.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/tag.ex")
    binding = [app_name: root_module(), tag_name: tag_name]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end

  defp inject_component_module_into_manager(component_type) do
    manager_path = "lib/#{otp_app()}/manager.ex"
    {before_components, after_components, list} = parse_manager(manager_path)

    new_list =
      component_type
      |> add_component_to_list(list)
      |> ensure_list_format()

    new_contents =
      [before_components, "def components do\n    ", new_list, "\n  end", after_components]
      |> IO.iodata_to_binary()
      |> Code.format_string!()

    Mix.shell().info([:green, "* injecting ", :reset, manager_path])
    File.write!(manager_path, [new_contents, "\n"])
  end

  defp parse_manager(path) do
    file = File.read!(path)
    [top, rest] = String.split(file, "def components do", parts: 2)
    [list, bottom] = String.split(rest, "end", parts: 2)

    {top, bottom, list}
  end

  defp add_component_to_list(component_type, list_as_string) do
    {result, _binding} = Code.eval_string(list_as_string)

    component_type
    |> full_component_module()
    |> then(&[&1 | result])
    |> inspect()
  end

  defp full_component_module(component_type) do
    Module.concat([root_module(), "Components", component_type])
  end

  # Adds a newline to ensure the list is formatted with one component per line
  defp ensure_list_format(list_as_string) do
    ["[" | rest] = String.graphemes(list_as_string)

    ["[\n" | rest]
  end
end
