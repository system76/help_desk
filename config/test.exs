use Mix.Config

config :help_desk,
  producer: {Broadway.DummyProducer, []}
