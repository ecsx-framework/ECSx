defmodule ECSx.MixProject do
  use Mix.Project

  @gh_url "https://github.com/APB9785/ECSx"

  def project do
    [
      app: :ecsx,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ECSx",
      source_url: @gh_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "An Entity-Component-System framework for Elixir"
  end

  defp package do
    [
      links: %{"GitHub" => @gh_url}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.1", only: :dev}
    ]
  end
end
