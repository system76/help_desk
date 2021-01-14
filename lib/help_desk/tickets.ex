defmodule HelpDesk.Tickets do
  alias Bottle.Support.V1.{Question, QuestionCreated, MacroApplied}
  alias HelpDesk.{Users, Zendesk}
  alias ZenEx.Entity.Ticket

  @callback create(struct()) :: struct() | {:error, String.t() | atom()}

  def create(%QuestionCreated{question: question}) do
    {:ok, submitter_id} = get_zendesk_user_id(question.submitter)

    custom_fields = Enum.reduce(question.custom_fields, [], &ticket_custom_fields(&1, &2, zendesk_custom_fields()))

    assignee_id = ticket_assignee(question, submitter_id)

    ticket = %Ticket{
      assignee_id: assignee_id,
      description: ticket_comment(question),
      custom_fields: custom_fields,
      requester_id: submitter_id,
      status: ticket_status(assignee_id, submitter_id),
      subject: question.subject,
      submitter_id: submitter_id,
      tags: question.tag
    }

    ZenEx.Model.Ticket.create(ticket)
  rescue
    e ->
      {:error, e.message}
  end

  def apply_macros(%MacroApplied{question: %{id: question_id}, macros: macros}),
    do: Enum.each(macros, &apply_macro(question_id, &1))

  defp apply_macro(zendesk_ticket_id, zendesk_macro_id) do
    with {:ok, %{body: %{"result" => changes}}} <-
           Zendesk.get("/api/v2/tickets/#{zendesk_ticket_id}/macros/#{zendesk_macro_id}/apply.json"),
         {:ok, %{body: %{"ticket" => _ticket}}} <- Zendesk.put("/api/v2/tickets/#{zendesk_ticket_id}.json", changes) do
      :ok
    else
      {:ok, %{body: %{"error" => reason}}} ->
        {:error, reason}
    end
  end

  defp get_zendesk_user_id(user) do
    %{id: zendesk_user_id} = Users.sync(user)
    {:ok, zendesk_user_id}
  end

  # TODO: Ask Sam if this assignment is necessary, it would not appear so based on their usage
  defp ticket_assignee(%Question{customer: user, submitter: user}, user), do: nil
  defp ticket_assignee(%Question{}, agent_zendesk_id), do: agent_zendesk_id

  defp ticket_comment(%Question{message: message, submitter: nil}), do: %{body: message, public: false}
  defp ticket_comment(%Question{message: message}), do: %{body: message}

  defp ticket_custom_fields({"order_id", value}, acc, config),
    do: zendesk_custom_field(:order_id, value, acc, config)

  defp ticket_custom_fields({"product_model", value}, acc, config),
    do: zendesk_custom_field(:product_model, value, acc, config)

  defp ticket_custom_fields({"product_serial", value}, acc, config),
    do: zendesk_custom_field(:product_serial, value, acc, config)

  defp ticket_custom_fields({"referrer", value}, acc, config),
    do: zendesk_custom_field(:referrer, value, acc, config)

  defp ticket_custom_fields({"security_codes", value}, acc, config),
    do: zendesk_custom_field(:security_codes, value, acc, config)

  defp ticket_custom_fields({_key, _value}, acc, _config),
    do: acc

  defp ticket_status(submitter_id, submitter_id), do: "pending"
  defp ticket_status(_, _), do: "new"

  defp zendesk_custom_field(key, value, acc, config) do
    id = Keyword.get(config, key)
    [%{id: id, value: value} | acc]
  end

  defp zendesk_custom_fields, do: Application.get_env(:zen_ex, :custom_fields)
end
