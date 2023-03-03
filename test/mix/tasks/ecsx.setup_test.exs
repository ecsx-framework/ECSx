Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.SetupTest do
  use ExUnit.Case

  import ECSx.MixHelper, only: [clean_tmp_dir: 0, sample_mixfile: 0]

  @config_path "config/config.exs"

  setup do
    File.mkdir!("tmp")
    File.cd!("tmp")
    File.mkdir!("lib")
    File.mkdir!("config")
    File.write!("mix.exs", sample_mixfile())

    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "generates manager and folders" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Setup.run([])

      manager_file = File.read!("lib/my_app/manager.ex")

      assert manager_file ==
               """
               defmodule MyApp.Manager do
                 @moduledoc \"\"\"
                 ECSx manager.
                 \"\"\"
                 use ECSx.Manager

                 setup do
                   # Load your initial components
                 end

                 # Declare all valid Component types
                 def components do
                   [
                     # MyApp.Components.SampleComponent
                   ]
                 end

                 # Declare all Systems to run
                 def systems do
                   [
                     # MyApp.Systems.SampleSystem
                   ]
                 end
               end
               """

      assert File.dir?("lib/my_app/components")
      assert File.dir?("lib/my_app/systems")
    end)
  end

  test "injects into basic config" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      File.write!(@config_path, "import Config\n")

      Mix.Tasks.Ecsx.Setup.run([])

      assert File.read!(@config_path) ==
               """
               import Config

               config :ecsx,
                 tick_rate: 20,
                 manager: MyApp.Manager
               """
    end)
  end

  test "injects into missing config" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Setup.run([])

      assert File.read!(@config_path) ==
               """
               import Config

               config :ecsx,
                 tick_rate: 20,
                 manager: MyApp.Manager
               """
    end)
  end

  test "injects into realistic config" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      config = """
      # This file is responsible for configuring your application
      # and its dependencies with the aid of the Config module.
      #
      # This configuration file is loaded before any dependency and
      # is restricted to this project.

      # General application configuration
      import Config

      config :my_app,
        ecto_repos: [MyApp.Repo]

      # Configures the endpoint
      config :my_app, MyAppWeb.Endpoint,
        url: [host: "localhost"],
        render_errors: [view: MyAppWeb.ErrorView, accepts: ~w(html json), layout: false],
        pubsub_server: MyApp.PubSub,
        live_view: [signing_salt: "foobar"]

      # Configures the mailer
      #
      # By default it uses the "Local" adapter which stores the emails
      # locally. You can see the emails in your browser, at "/dev/mailbox".
      #
      # For production it's recommended to configure a different adapter
      # at the `config/runtime.exs`.
      config :my_app, MyApp.Mailer, adapter: Swoosh.Adapters.Local

      # Swoosh API client is needed for adapters other than SMTP.
      config :swoosh, :api_client, false

      # Configure esbuild (the version is required)
      config :esbuild,
      version: "0.14.41",
      default: [
      args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
      ]

      # Configures Elixir's Logger
      config :logger, :console,
      format: "$time $metadata[$level] $message\n",
      metadata: [:request_id]

      # Use Jason for JSON parsing in Phoenix
      config :phoenix, :json_library, Jason

      # Import environment specific config. This must remain at the bottom
      # of this file so it overrides the configuration defined above.
      import_config "\#{config_env()}.exs"
      """

      File.write!(@config_path, config)

      Mix.Tasks.Ecsx.Setup.run([])

      assert File.read!(@config_path) == """
             # This file is responsible for configuring your application
             # and its dependencies with the aid of the Config module.
             #
             # This configuration file is loaded before any dependency and
             # is restricted to this project.

             # General application configuration
             import Config

             config :my_app,
               ecto_repos: [MyApp.Repo]

             # Configures the endpoint
             config :my_app, MyAppWeb.Endpoint,
               url: [host: "localhost"],
               render_errors: [view: MyAppWeb.ErrorView, accepts: ~w(html json), layout: false],
               pubsub_server: MyApp.PubSub,
               live_view: [signing_salt: "foobar"]

             # Configures the mailer
             #
             # By default it uses the "Local" adapter which stores the emails
             # locally. You can see the emails in your browser, at "/dev/mailbox".
             #
             # For production it's recommended to configure a different adapter
             # at the `config/runtime.exs`.
             config :my_app, MyApp.Mailer, adapter: Swoosh.Adapters.Local

             # Swoosh API client is needed for adapters other than SMTP.
             config :swoosh, :api_client, false

             # Configure esbuild (the version is required)
             config :esbuild,
             version: "0.14.41",
             default: [
             args:
             ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
             cd: Path.expand("../assets", __DIR__),
             env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
             ]

             # Configures Elixir's Logger
             config :logger, :console,
             format: "$time $metadata[$level] $message\n",
             metadata: [:request_id]

             # Use Jason for JSON parsing in Phoenix
             config :phoenix, :json_library, Jason

             config :ecsx,
               tick_rate: 20,
               manager: MyApp.Manager

             # Import environment specific config. This must remain at the bottom
             # of this file so it overrides the configuration defined above.
             import_config "\#{config_env()}.exs"
             """
    end)
  end

  test "--no-folders option" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Setup.run(["--no-folders"])

      assert File.exists?("lib/my_app/manager.ex")
      refute File.dir?("lib/my_app/components")
      refute File.dir?("lib/my_app/systems")
    end)
  end
end
