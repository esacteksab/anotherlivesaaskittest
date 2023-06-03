defmodule AnotherTest.AccountsTest do
  use AnotherTest.DataCase, async: true

  import AnotherTest.AccountsFixtures
  import AnotherTest.UsersFixtures

  alias AnotherTest.Accounts
  alias AnotherTest.Accounts.Account
  alias AnotherTest.Accounts.Membership
  alias AnotherTest.Accounts.Invitation

  defp setup_user(_) do
    user = user_fixture()
    {:ok, user: user}
  end

  defp setup_account(_) do
    account = account_fixture()
    {:ok, account: account}
  end

  describe "accounts" do
    @invalid_attrs %{name: nil, personal: nil}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Enum.member?(Accounts.list_accounts(), account)
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{name: "some name", personal: false}

      user = user_fixture()

      assert {:ok, %Account{} = account} = Accounts.create_account(user, valid_attrs)
      assert account.name == "some name"
      assert account.personal == false
    end

    test "create_account/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(user, @invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      update_attrs = %{name: "some updated name", personal: false}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.name == "some updated name"
      assert account.personal == false
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end

    test "with_members/1 returns an account with members preloaded" do
      account = account_fixture()
      assert %Account{members: []} = Accounts.with_members(account)
      membership_fixture(account)
      assert %Account{members: [_|_]} = Accounts.with_members(account)
    end

    test "can_be_accessed_by_a_user?/2 returns false if a user cant access the account" do
      account = account_fixture()
      user = user_fixture()
      assert Accounts.can_be_accessed_by_a_user?(account, user) == false
    end

    test "can_be_accessed_by_a_user?/2 returns true if a user can access the account" do
      account = account_fixture()
      user = user_fixture()
      membership_fixture(account, user)
      assert Accounts.can_be_accessed_by_a_user?(account, user) == true
    end

    test "can_be_accessed_by_a_user?/2 returns true if its a users personal account" do
      %{accounts: [account]} = user = AnotherTest.Users.with_memberships(user_fixture())

      assert account.personal == true
      assert Accounts.can_be_accessed_by_a_user?(account, user) == true
    end
  end

  describe "memberships" do
    setup [:setup_user, :setup_account]

    @invalid_attrs %{role: nil}

    test "list_memberships/1 returns all memberships for an account", %{account: account} do
      membership = membership_fixture(account)
      assert Accounts.list_memberships(account) == [membership]
    end

    test "get_membership!/1 returns the membership with given id", %{account: account} do
      membership = membership_fixture(account)
      assert Accounts.get_membership!(account, membership.id) == membership
    end

    test "create_membership/1 with valid data creates a membership", %{user: user, account: account} do
      valid_attrs = %{}

      assert {:ok, %Membership{} = _membership} = Accounts.create_membership(account, user, valid_attrs)
    end

    test "create_membership/1 with invalid data returns error changeset", %{user: user, account: account} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_membership(account, user, @invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership" do
      membership = membership_fixture()
      update_attrs = %{}

      assert {:ok, %Membership{} = _membership} = Accounts.update_membership(membership, update_attrs)
    end

    test "update_membership/2 with invalid data returns error changeset", %{account: account} do
      membership = membership_fixture(account)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_membership(membership, @invalid_attrs)
      assert membership == Accounts.get_membership!(account, membership.id)
    end

    test "delete_membership/1 deletes the membership", %{account: account} do
      membership = membership_fixture(account)
      assert {:ok, %Membership{}} = Accounts.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_membership!(account, membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Accounts.change_membership(membership)
    end
  end

  describe "invitations" do
    setup [:setup_user, :setup_account]

    @invalid_attrs %{accepted_at: nil, email: nil}

    test "list_invitations/1 returns all invitations", %{account: account} do
      invitation = invitation_fixture(account)
      assert Accounts.list_invitations(account) == [invitation]
    end

    test "list_invitations_for_user/1 returns all invitations for a user", %{account: account} do
      email = "invite-me@example.com"
      user_that_invites = user_fixture()
      user = user_fixture(%{email: email})

      invitation_fixture(account, user_that_invites, %{email: email})
      assert [invitation] = Accounts.list_invitations_for_user(user)
      assert invitation.account == account
      assert invitation.invited_by == user_that_invites
      assert invitation.email == email
    end

    test "list_invitations_for_user/1 doesnt return other peoples invitations" do
      user = user_fixture()
      invitation_fixture()
      assert Accounts.list_invitations_for_user(user) == []
    end

    test "get_invitation!/1 returns the invitation with given id", %{account: account} do
      invitation = invitation_fixture(account)
      assert Accounts.get_invitation!(account, invitation.id) == invitation
    end

    test "create_invitation/1 with valid data creates a invitation", %{account: account, user: user} do
      valid_attrs = %{accepted_at: ~U[2022-05-05 11:06:00Z], email: "some@email.com"}

      assert {:ok, %Invitation{} = invitation} = Accounts.create_invitation(account, user, valid_attrs)
      assert invitation.accepted_at == ~U[2022-05-05 11:06:00Z]
      assert invitation.email == "some@email.com"
    end

    test "create_invitation/1 with invalid data returns error changeset", %{account: account, user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_invitation(account, user, @invalid_attrs)
    end

    test "update_invitation/2 with valid data updates the invitation" do
      invitation = invitation_fixture()
      update_attrs = %{accepted_at: ~U[2022-05-06 11:06:00Z]}

      assert {:ok, %Invitation{} = invitation} = Accounts.update_invitation(invitation, update_attrs)
      assert invitation.accepted_at == ~U[2022-05-06 11:06:00Z]
    end

    test "update_invitation/2 with invalid data returns error changeset", %{account: account} do
      invitation = invitation_fixture(account)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_invitation(invitation, @invalid_attrs)
      assert invitation == Accounts.get_invitation!(account, invitation.id)
    end

    test "delete_invitation/1 deletes the invitation", %{account: account} do
      invitation = invitation_fixture(account)
      assert {:ok, %Invitation{}} = Accounts.delete_invitation(invitation)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_invitation!(account, invitation.id) end
    end

    test "change_invitation/1 returns a invitation changeset" do
      invitation = invitation_fixture()
      assert %Ecto.Changeset{} = Accounts.change_invitation(invitation)
    end
  end
end
