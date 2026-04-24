defmodule ElxVast.MixProject do
  use Mix.Project

  def project do
    [
      app: :elx_vast,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ElxVAST",
      source_url: "https://github.com/arodionov53/elx_vast",
      docs: [
        main: "ElxVast",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    A comprehensive VAST (Video Ad Serving Template) 4.1 XML validator for Elixir.
    Validates VAST documents according to the IAB VAST 4.1 specification with
    detailed error reporting and complete schema compliance.
    """
  end

  defp package do
    [
      name: "elx_vast",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/arodionov53/elx_vast"}
    ]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.7.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:benchee, "~> 1.3", only: :dev}
    ]
  end
end
