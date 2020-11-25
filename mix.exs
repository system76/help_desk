defmodule HelpDesk.MixProject do
  use Mix.Project

  def project do
    [
      app: :help_desk,
      version: "0.1.0",
      elixir: "~> 1.10",
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
      {:bottle, github: "system76/bottle", branch: "elixir"},
      {:broadway_sqs, "~> 0.6.0"},
      {:saxy, "~> 1.1"},
      {:hackney, "~> 1.16"},
      {:jason, "~> 1.2", override: true},
      {:credo, "~> 1.3", only: [:dev, :test]}
    ]
  end
end
