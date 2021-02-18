use Mix.Config

config :logger,
  backends: [LoggerJSON],
  level: :info

config :appsignal, :config, active: true

config :help_desk, HelpDesk.Tracer, disabled?: false
