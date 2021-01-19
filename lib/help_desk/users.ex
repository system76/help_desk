defmodule HelpDesk.Users do
  alias Bottle.Account.V1.{User, UserCreated}
  alias ZenEx.Entity.User, as: ZendeskUser

  @callback sync(struct()) :: struct() | {:error, String.t() | atom()}

  def sync(%UserCreated{user: user}) do
    sync(user)
  end

  def sync(%User{} = user) do
    attrs = zendesk_attributes(user)

    with %ZendeskUser{} = zendesk_user <- ZenEx.Model.User.create(attrs) do
      maybe_update_primary_email(zendesk_user, attrs)
    end
  end

  defp full_name(user), do: String.trim("#{user.first_name} #{user.last_name}")

  defp maybe_update_primary_email(%{email: email} = zendesk_user, %{email: email}) do
    zendesk_user
  end

  defp maybe_update_primary_email(zendesk_user, user) do
    with %{entites: identities} <- ZenEx.Model.Identity.list(zendesk_user),
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
      email: user.email,
      name: full_name(user),
      external_id: user.id,
      phone: user.phone_number,
      verified: true,
      user_fields: user_fields(user)
    }
  end
end
