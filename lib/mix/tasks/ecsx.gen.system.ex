defmodule Mix.Tasks.Ecsx.Gen.System do
  @shortdoc "Generates a new ECSx System"

  @moduledoc """
  Generates a new System for an ECSx application.

      $ mix ecsx.gen.system Foo

  The only argument accepted is a module name for the System.
  """

  use Mix.Task
  import Mix.Tasks.ECSx.Helpers, only: [otp_app: 0, root_module: 0]

  @doc false
  def run([]) do
    Mix.raise("""
    Missing argument.

    mix ecsx.gen.system expects a system module name (in PascalCase).

    For example:

        mix ecsx.gen.system MySystem

    """)
  end

  def run([system_name | _] = _args) do
    create_system_file(system_name)
    inject_system_module_into_manager(system_name)
  end

  defp create_system_file(system_name) do
    filename = Macro.underscore(system_name)
    target = "lib/#{otp_app()}/systems/#{filename}.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/system.ex")
    binding = [app_name: root_module(), system_name: system_name]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end

  defp inject_system_module_into_manager(system_name) do
    manager_path = "lib/#{otp_app()}/manager.ex"
    Mix.shell().info([:green, "* injecting ", :reset, manager_path])

    {before_systems, after_systems, list} = parse_manager(manager_path)

    new_list =
      system_name
      |> add_system_to_list(list)
      |> ensure_list_format()

    new_contents =
      [before_systems, "def systems do\n    ", new_list, "\n  end", after_systems]
      |> IO.iodata_to_binary()
      |> Code.format_string!()

    Mix.shell().info([:green, "* injecting ", :reset, manager_path])
    File.write!(manager_path, [new_contents, "\n"])
  end

  defp parse_manager(path) do
    file = File.read!(path)
    [top, rest] = String.split(file, "def systems do", parts: 2)
    [list, bottom] = String.split(rest, "end", parts: 2)

    {top, bottom, list}
  end

  defp add_system_to_list(system_name, list_as_string) do
    {result, _binding} = Code.eval_string(list_as_string)

    system_name
    |> full_system_module()
    |> then(&[&1 | result])
    |> inspect()
  end

  defp full_system_module(system_name) do
    Module.concat([root_module(), "Systems", system_name])
  end

  # Adds a newline to ensure the list is formatted with one system per line
  defp ensure_list_format(list_as_string) do
    ["[" | rest] = String.graphemes(list_as_string)

    ["[\n" | rest]
  end
end
