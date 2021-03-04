defmodule HelpDesk.MixProject do
  use Mix.Project

  def project do
    [
      app: :help_desk,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        help_desk: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HelpDesk.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:appsignal, "~> 1.0"},
      {:bottle, github: "system76/bottle", ref: "041d8ae"},
      {:broadway_sqs, "~> 0.6.0"},
      {:credo, "~> 1.3", only: [:dev, :test]},
      {:decorator, "~> 1.2"},
      {:finch, "~> 0.3"},
      {:hackney, "~> 1.16"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2", override: true},
      {:logger_json, github: "Nebo15/logger_json", ref: "8e4290a"},
      {:mox, "~> 1.0", only: :test},
      {:poison, "~> 4.0", override: true},
      {:saxy, "~> 1.1"},
      {:spandex_datadog, "~> 1.1"},
      {:spandex, "~> 3.0.3"},
      {:telemetry, "~> 0.4"},
      {:zen_ex, github: "system76/zen_ex", ref: "051aa25"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
