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

  def inject_component_module_into_manager(component_type) do
    manager_path = "lib/#{otp_app()}/manager.ex"
    {before_components, after_components, list} = parse_manager_components(manager_path)

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

  defp parse_manager_components(path) do
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
