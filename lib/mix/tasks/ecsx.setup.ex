defmodule Mix.Tasks.Ecsx.Setup do
  @shortdoc "Generates manager process for ECSx"

  @moduledoc """
  Generates the manager process which runs an ECSx application.

      $ mix ecsx.setup

  """

  use Mix.Task
  import Mix.Tasks.ECSx.Helpers, only: [otp_app: 0, root_module: 0]

  @doc false
  def run(_args) do
    create_manager()
    create_sample_aspect()
    create_sample_system()

    Mix.shell().info("""

    Next you must add the manager to your supervision tree in application.ex:
        def start(_type, _args) do
          children = [
            ...
            #{inspect(root_module())}.Manager,
            ...
          ]
        end
    """)
  end

  defp create_manager do
    target = "lib/#{otp_app()}/manager.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/manager.ex")
    binding = [app_name: root_module()]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end

  defp create_sample_aspect do
    target = "lib/#{otp_app()}/aspects/sample_aspect.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/aspect.ex")
    binding = [app_name: root_module(), fields: ":entity_id, :value", aspect_name: "SampleAspect"]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end

  defp create_sample_system do
    target = "lib/#{otp_app()}/systems/sample_system.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/system.ex")
    binding = [app_name: root_module(), system_name: "SampleSystem"]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end
end
