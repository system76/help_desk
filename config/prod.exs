use Mix.Config

config :logger,
  backends: [LoggerJSON],
  level: :info

config :help_desk, HelpDesk.Tracer, disabled?: false
