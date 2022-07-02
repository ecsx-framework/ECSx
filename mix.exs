defmodule ECSx.MixProject do
  use Mix.Project

  @gh_url "https://github.com/APB9785/ECSx"
  @version "0.1.0"

  def project do
    [
      app: :ecsx,
      version: @version,
      elixir: "~> 1.13",
      deps: deps(),
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
      extra_applications: [:logger, :eex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      links: %{"GitHub" => @gh_url}
    ]
  end

  defp docs do
    [
      main: "ECSx",
      source_ref: "v#{@version}",
      logo: nil,
      extra_section: "GUIDES",
      source_url: @gh_url
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.1", only: :dev}
    ]
  end
end
