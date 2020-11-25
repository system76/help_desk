use Mix.Config

config :help_desk,
  producer: {Broadway.DummyProducer, []},
  handlers: [
    organizations: HelpDesk.MockOrganizations,
    tickets: HelpDesk.MockTickets,
    users: HelpDesk.MockUsers
  ]
