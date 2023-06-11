defmodule AnotherTest.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AnotherTest.Accounts` context.
  """

  import AnotherTest.UsersFixtures

  alias AnotherTest.Accounts
  alias AnotherTest.Accounts.Account
  alias AnotherTest.Users.User

  @doc """
  Generate a account.
  """
  def account_fixture(), do: account_fixture(%{})
  def account_fixture(%User{} = user), do: account_fixture(user, %{})

  def account_fixture(attrs) do
    user = user_fixture()
    account_fixture(user, attrs)
  end

  def account_fixture(%User{} = user, attrs) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        personal: false
      })

    {:ok, account} = Accounts.create_account(user, attrs)

    Accounts.get_account!(account.id)
  end

  @doc """
  Generate a membership.
  """
  def membership_fixture() do
    account = account_fixture()
    user = user_fixture()
    membership_fixture(account, user)
  end

  def membership_fixture(%Account{} = account) do
    user = user_fixture()
    membership_fixture(account, user)
  end

  def membership_fixture(%Account{} = account, %User{} = user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{})

    {:ok, membership} = Accounts.create_membership(account, user, attrs)

    Accounts.get_membership!(account, membership.id)
  end

  @doc """
  Generate a invitation.
  """
  def invitation_fixture() do
    account = account_fixture()
    user = user_fixture()
    invitation_fixture(account, user)
  end

  def invitation_fixture(%Account{} = account) do
    user = user_fixture()
    invitation_fixture(account, user)
  end

  def invitation_fixture(%Account{} = account, %User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: unique_user_email()
      })

    {:ok, invitation} = Accounts.create_invitation(account, user, attrs)

    Accounts.get_invitation!(account, invitation.id)
  end
end
