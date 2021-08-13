defmodule HelpDesk.Organizations do
  use Spandex.Decorators

  alias Bottle.Account.V1.{OrganizationCreated, OrganizationLeft, OrganizationJoined}
  alias ZenEx.Entity.Organization

  @callback create(struct()) :: struct() | {:error, String.t() | atom()}
  @callback join(struct()) :: struct() | {:error, String.t() | atom()}
  @callback leave(struct()) :: struct() | {:error, String.t() | atom()}

  @decorate span(service: :zendesk, type: :web)
  def create(%OrganizationCreated{organization: %{id: id, name: name}}) do
    ZenEx.Model.Organization.create(%Organization{external_id: id, name: name})
  end

  @decorate span(service: :zendesk, type: :web)
  def join(%OrganizationJoined{organization: organization, user: user}) do
    with %{entities: [zendesk_user]} <- ZenEx.Model.User.search(external_id: user.id),
         %{entities: [zendesk_organization]} <- ZenEx.Model.Organization.search(external_id: organization.id) do
      ZenEx.Model.OrganizationMembership.create(zendesk_organization, zendesk_user)
    end
  end

  @decorate span(service: :zendesk, type: :web)
  def leave(%OrganizationLeft{organization: organization, user: user}) do
    with %{entities: [zendesk_user]} <- ZenEx.Model.User.search(external_id: user.id),
         %{entities: memberships} <- ZenEx.Model.OrganizationMembership.list(zendesk_user),
         %{id: organization_membership_id} <-
           Enum.find(memberships, &(&1.external_id == organization.id)) do
      ZenEx.Model.OrganizationMembership.destroy(organization_membership_id)
    end
  end
end
