defmodule HelpDesk.Users do
  use Appsignal.Instrumentation.Decorators
  use Spandex.Decorators

  alias Bottle.Account.V1.{User, UserDeleted}
  alias ZenEx.Entity.User, as: ZendeskUser

  @callback delete(struct()) :: struct() | {:error, String.t() | atom()}
  @callback sync(struct()) :: struct() | {:error, String.t() | atom()}

  @decorate transaction(:zendesk)
  @decorate span(service: :zendesk, type: :web)
  def delete(%UserDeleted{user: user}) do
    with %{entities: [%ZendeskUser{id: zendesk_user_id}]} <- ZenEx.Model.User.list(external_id: user.id),
         %ZendeskUser{} <- ZenEx.Model.User.destroy(zendesk_user_id) do
      :ok
    end
  end

  def sync(%{user: user}) do
    sync(user)
  end

  @decorate transaction(:zendesk)
  @decorate span(service: :zendesk, type: :web)
  def sync(%User{} = user) do
    attrs = zendesk_attributes(user)

    with %ZendeskUser{} = zendesk_user <- ZenEx.Model.User.create_or_update(attrs) do
      maybe_update_primary_email(zendesk_user, attrs)
    end
  end

  defp full_name(user), do: String.trim("#{user.first_name} #{user.last_name}")

  defp maybe_update_primary_email(%{email: email} = zendesk_user, %{email: email}) do
    zendesk_user
  end

  @decorate transaction(:zendesk)
  @decorate span(service: :zendesk, type: :web)
  defp maybe_update_primary_email(zendesk_user, user) do
    with %{entities: identities} <- ZenEx.Model.Identity.list(zendesk_user),
         identity = Enum.find(identities, &(&1.value == user.email)),
         %{primary: true} <- ZenEx.Model.Identity.make_primary(identity) do
      zendesk_user
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp user_fields(%{type: :ACCOUNT_TYPE_INDIVIDUAL} = user) do
    %{
      account_type: "individual",
      newsletter: user.newsletter
    }
  end

  defp user_fields(user) do
    %{
      account_type: "business",
      company_name: user.company_name,
      reseller: user.account_type == :ACCOUNT_TYPE_RESELLER,
      newsletter: user.newsletter
    }
  end

  def zendesk_attributes(user) do
    %ZendeskUser{
      email: String.downcase(user.email),
      name: full_name(user),
      external_id: user.id,
      phone: user.phone_number,
      verified: true,
      user_fields: user_fields(user)
    }
  end
end
