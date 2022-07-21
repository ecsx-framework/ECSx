defmodule Mix.Tasks.Ecsx.Setup do
  @shortdoc "Generates manager process for ECSx"

  @moduledoc """
  Generates the manager process which runs an ECSx application.

      $ mix ecsx.setup

  This setup will generate `manager.ex` and empty folders for aspects and systems.

  If you don't want to generate the folders, you can provide option `--no-folders`
  """

  use Mix.Task
  import Mix.Tasks.ECSx.Helpers, only: [otp_app: 0, root_module: 0]

  @doc false
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [folders: :boolean])

    create_manager()

    if Keyword.get(opts, :folders, true) do
      create_folders()
    end

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

  defp create_folders do
    Mix.Generator.create_directory("lib/#{otp_app()}/aspects")
    Mix.Generator.create_directory("lib/#{otp_app()}/systems")
  end
end
