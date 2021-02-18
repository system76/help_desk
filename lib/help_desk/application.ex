defmodule HelpDesk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    children = [
      {SpandexDatadog.ApiServer, Application.get_env(:help_desk, SpandexDatadog.ApiServer)},
      {Finch, name: Sparrow},
      {HelpDesk.Broadway, []}
    ]

    Logger.info("Starting HelpDesk")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelpDesk.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
