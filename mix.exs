defmodule ECSx.MixProject do
  use Mix.Project

  @gh_url "https://github.com/APB9785/ECSx"
  @version "0.3.1"

  def project do
    [
      app: :ecsx,
      version: @version,
      elixir: "~> 1.13",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,

      # Hex
      description: "An Entity-Component-System framework for Elixir",
      package: package(),

      # Docs
      name: "ECSx",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ECSx, []},
      extra_applications: [:logger, :eex, :mix]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:telemetry, "~> 1.0"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["Andrew P Berrien"],
      licenses: ["GPL-3.0"],
      links: %{
        "Changelog" => "#{@gh_url}/blob/master/CHANGELOG.md",
        "GitHub" => @gh_url
      }
    ]
  end

  defp docs do
    [
      main: "ECSx",
      source_ref: "v#{@version}",
      logo: nil,
      extra_section: "GUIDES",
      source_url: @gh_url,
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "guides/ecs_design.md",
      "guides/installation.md",
      "guides/tutorial/initial_setup.md",
      "guides/tutorial/backend_basics.md",
      "guides/tutorial/web_frontend_liveview.md"
    ]
  end

  defp groups_for_extras do
    [
      "Tutorial Project": ~r/guides\/tutorial\/.?/
    ]
  end
end
