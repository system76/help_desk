use Mix.Config

config :help_desk,
  producer: {BroadwayRabbitMQ.Producer, queue: "", connection: ""},
  handlers: [
    organizations: HelpDesk.Organizations,
    tickets: HelpDesk.Tickets,
    users: HelpDesk.Users
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id, :organization_id, :question_id, :trace_id, :span_id],
  level: :info

config :logger_json, :backend,
  formatter: LoggerJSON.Formatters.DatadogLogger,
  metadata: :all

config :help_desk, HelpDesk.Tracer,
  service: :help_desk,
  adapter: SpandexDatadog.Adapter,
  disabled?: true

config :help_desk, SpandexDatadog.ApiServer,
  batch_size: 2,
  http: HTTPoison,
  host: "127.0.0.1"

config :spandex, :decorators, tracer: HelpDesk.Tracer

import_config "#{Mix.env()}.exs"
