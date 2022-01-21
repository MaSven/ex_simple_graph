defmodule SimpleGraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_graph,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/MaSven/ex_simple_graph",
      test_coverage: [tool: ExCoveralls],
preferred_cli_env: [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:uuid, "~> 1.1"},
      {:mix_audit, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.4", only: :test,runtime: false},
    ]
  end

  defp description() do
    "A simple datastructure, that does not implement any algorithms for traversing the graph."
  end

  defp package() do
    [
      name: "simple_graph_datastructure",
      licenses: ["AGPL 3.0"],
      links: %{"Github" => "https://github.com/MaSven/ex_simple_graph"},
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*  LICENSE*
                 CHANGELOG*  ),

    ]
  end




end
