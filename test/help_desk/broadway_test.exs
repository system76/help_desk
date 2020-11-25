defmodule HelpDesk.BroadwayTest do
  use ExUnit.Case

  import HelpDesk.BroadwayHelpers
  import Mox

  alias Bottle.Account.V1.{Organization, OrganizationCreated, OrganizationJoined, OrganizationLeft, UserCreated, User}
  alias ZenEx.Entity.Organization, as: ZendeskOrganization
  alias ZenEx.Entity.OrganizationMembership, as: ZendeskOrganizationMembership
  alias ZenEx.Entity.User, as: ZendeskUser

  describe "handle_message/3" do
    setup :set_mox_from_context
    setup :verify_on_exit!

    test "creates a new Zendesk organization" do
      expect(HelpDesk.MockOrganizations, :create, fn _message ->
        %ZendeskOrganization{id: 1}
      end)

      {:organization_created, %OrganizationCreated{organization: %Organization{name: "Test", id: "1"}}}
      |> bottled_message()
      |> test_message()

      assert_receive {:ack, _ref, successful, []}
      assert 1 == length(successful)
    end

    test "updates a new Zendesk user's organization membership" do
      expect(HelpDesk.MockOrganizations, :join, fn _message ->
        %ZendeskOrganizationMembership{id: 1}
      end)

      {:organization_joined, %OrganizationJoined{organization: %Organization{}, user: %User{}}}
      |> bottled_message()
      |> test_message()

      assert_receive {:ack, _ref, successful, []}
      assert 1 == length(successful)
    end

    test "removes a new Zendesk user from the organization" do
      expect(HelpDesk.MockOrganizations, :leave, fn _message ->
        %ZendeskOrganizationMembership{id: 1}
      end)

      {:organization_left, %OrganizationLeft{organization: %Organization{}, user: %User{}}}
      |> bottled_message()
      |> test_message()

      assert_receive {:ack, _ref, successful, []}
      assert 1 == length(successful)
    end

    test "syncs a user with Zendesk" do
      expect(HelpDesk.MockUsers, :sync, fn _message ->
        %ZendeskUser{id: 1}
      end)

      {:user_created, %UserCreated{user: %User{}}}
      |> bottled_message()
      |> test_message()

      assert_receive {:ack, _ref, successful, []}
      assert 1 == length(successful)
    end
  end
end
