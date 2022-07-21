defmodule Mix.Tasks.Ecsx.Gen.System do
  @shortdoc "Generates a new ECSx System"

  @moduledoc """
  Generates a new System for an ECSx application.

      $ mix ecsx.gen.system Foo

  The only argument accepted is a module name for the System.
  """

  use Mix.Task
  import Mix.Tasks.ECSx.Helpers, only: [otp_app: 0, root_module: 0, write_file: 2]

  @doc false
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
    pattern = "def systems do\n    [\n"
    Mix.shell().info([:green, "* injecting ", :reset, manager_path])

    manager_path
    |> File.read!()
    |> String.split(pattern, parts: 2)
    |> Enum.intersperse(pattern <> "      #{inspect(root_module())}.Systems.#{system_name},\n")
    |> write_file(manager_path)
  end
end
