defmodule Mix.Tasks.Ecsx.Setup do
  @shortdoc "Generates manager process for ECSx"

  @moduledoc """
  Generates the Manager process which runs an ECSx application.

      $ mix ecsx.setup

  This setup will generate `manager.ex` and empty folders for components and systems.

  If you don't want to generate the folders, you can provide option `--no-folders`
  """

  use Mix.Task

  import Mix.Generator

  alias Mix.Tasks.ECSx.Helpers

  @components_list "[\n      # MyApp.Components.SampleComponent\n    ]"
  @systems_list "[\n      # MyApp.Systems.SampleSystem\n    ]"

  @doc false
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [folders: :boolean])

    create_manager()

    inject_config()

    if Keyword.get(opts, :folders, true),
      do: create_folders()

    Mix.shell().info("ECSx setup complete!")
  end

  defp create_manager do
    target = "lib/#{Helpers.otp_app()}/manager.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/manager.ex")

    binding = [
      app_name: Helpers.root_module(),
      components_list: @components_list,
      systems_list: @systems_list
    ]

    create_file(target, EEx.eval_file(source, binding))
  end

  defp inject_config do
    config = Mix.Project.config()
    config_path = config[:config_path] || "config/config.exs"
    opts = [root_module: Helpers.root_module()]

    case File.read(config_path) do
      {:ok, file} ->
        [header | chunks] = String.split(file, "\n\n")
        header = String.trim(header)
        chunks = List.insert_at(chunks, -2, config_template(opts))
        new_contents = Enum.join([header | chunks], "\n\n")

        Mix.shell().info([:green, "* injecting ", :reset, config_path])
        File.write(config_path, String.trim(new_contents) <> "\n")

      {:error, _} ->
        create_file(config_path, "import Config\n\n" <> config_template(opts) <> "\n")
    end
  end

  defp create_folders do
    otp_app = Helpers.otp_app()
    create_directory("lib/#{otp_app}/components")
    create_directory("lib/#{otp_app}/systems")
  end

  embed_template(
    :config,
    "config :ecsx,\n  tick_rate: 20,\n  manager: <%= @root_module %>.Manager"
  )
end
