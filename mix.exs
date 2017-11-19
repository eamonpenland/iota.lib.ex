defmodule Iota.Mixfile do
  use Mix.Project

  def project do
    [app: :iota_lib,
     version: "0.0.1",
     elixir: "~> 1.1-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     description: "An Elixir wrapper around the IOTA node RPC API.",
     deps: deps(),
     docs: docs()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpotion]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package() do
    [files: ["lib", "config", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Guillaume Ballet"],
      licenses: ["Unlicense"],
      links: %{"GitHub": "https://github.com/peaqio/iota.lib.ex"}]
  end

  defp docs do
    [extras: ["README.md"]]
  end
end
