defmodule HelpDesk.Broadway do
  use Broadway
  use Appsignal.Instrumentation.Decorators

  require Logger

  def start_link(_opts) do
    producer_module = Application.fetch_env!(:help_desk, :producer)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: producer_module
      ],
      processors: [
        default: [concurrency: 2]
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 2000
        ]
      ]
    )
  end

  @impl true
  @decorate transaction(:queue)
  def handle_message(_, message, _context) do
    bottle =
      message.data
      |> URI.decode()
      |> Bottle.Core.V1.Bottle.decode()

    Bottle.RequestId.read(:queue, bottle)

    with {:error, reason} <- notify_handler(bottle.resource) do
      Logger.error(reason)
    end

    message
  end

  @impl true
  def handle_batch(_, messages, _, _) do
    messages
  end

  @impl true
  def handle_failed([failed_message], _context) do
    Appsignal.send_error(%RuntimeError{}, "Failed Broadway Message", [], %{}, nil, fn transaction ->
      Appsignal.Transaction.set_sample_data(transaction, "message", %{data: failed_message.data})
    end)

    [failed_message]
  end

  defp notify_handler({:user_created, message}) do
    Logger.info("Handling User Created message")
    notify_configured_handler(:users, :sync, message)
  end

  defp notify_handler({:question_created, message}) do
    Logger.info("Handling Question Created message")
    notify_configured_handler(:tickets, :create, message)
  end

  defp notify_handler({:macro_applied, message}) do
    Logger.info("Handling Macro Applied message")
    notify_configured_handler(:tickets, :apply_macros, message)
  end

  defp notify_handler({:organization_created, message}) do
    Logger.info("Handling Organization Created message")
    notify_configured_handler(:organizations, :create, message)
  end

  defp notify_handler({:organization_joined, message}) do
    Logger.info("Handling Organization Joined message")
    notify_configured_handler(:organizations, :join, message)
  end

  defp notify_handler({:organization_left, message}) do
    Logger.info("Handling Organization Left message")
    notify_configured_handler(:organizations, :leave, message)
  end

  defp notify_handler(_) do
    Logger.debug("Ignoring message")
    :ignored
  end

  defp notify_configured_handler(type, function, args) do
    type
    |> configured_handler()
    |> apply(function, [args])
  end

  defp configured_handler(type) do
    :help_desk
    |> Application.get_env(:handlers)
    |> Keyword.get(type)
  end
end
