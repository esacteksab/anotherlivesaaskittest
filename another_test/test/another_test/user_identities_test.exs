defmodule AnotherTest.UserIdentitiesTest do
  use AnotherTest.DataCase

  import AnotherTest.UsersFixtures
  import AnotherTest.UserIdentitiesFixtures

  alias AnotherTest.UserIdentities
  alias AnotherTest.UserIdentities.UserIdentity

  def setup_user(_) do
    user = user_fixture()
    {:ok, user: user}
  end

  describe "find_or_create_user when user exists and user_identity exists" do
    setup [:setup_user]

    test "find_or_create_user/1 it returns ok-user-tuple", %{user: user} do
      auth = ueberauth_response(%{email: user.email})
      user_identity_fixture(user, %{uid: auth.uid, provider: auth.provider})
      assert UserIdentities.find_or_create_user(auth) == {:ok, user}
    end
  end

  describe "find_or_create_user when user exists and user_identity exists but email does not match" do
    setup [:setup_user]

    test "find_or_create_user/1 it returns ok-user-tuple", %{user: user} do
      auth = ueberauth_response(%{email: "some_other_mail@example.com"})
      user_identity_fixture(user, %{uid: auth.uid, provider: auth.provider})
      assert UserIdentities.find_or_create_user(auth) == {:ok, user}
    end
  end

  describe "find_or_create_user with existing user but new user_identity" do
    setup [:setup_user]

    test "find_or_create_user/1 it returns error-user-tuple", %{user: user} do
      auth = ueberauth_response(%{email: user.email})
      assert UserIdentities.find_or_create_user(auth) == {:error, user}
    end
  end

  describe "find_or_create_user with a new user_identity" do
    test "find_or_create_user/1 it returns ok-account-tuple" do
      auth = ueberauth_response(%{email: "new_user@example.com"})

      assert {:just_created, %AnotherTest.Users.User{email: "new_user@example.com"}} =
               UserIdentities.find_or_create_user(auth)
    end
  end

  describe "user_identities" do
    setup [:setup_user]

    @invalid_attrs %{provider: nil, uid: nil}

    test "list_user_identities/0 returns all user_identities", %{user: user} do
      user_identity = user_identity_fixture(user)
      assert UserIdentities.list_user_identities(user) == [user_identity]
    end

    test "get_user_identity!/1 returns the user_identity with given id", %{user: user} do
      user_identity = user_identity_fixture(user)
      assert UserIdentities.get_user_identity!(user, user_identity.id) == user_identity
    end

    test "create_user_identity/1 with valid data creates a user_identity", %{user: user} do
      valid_attrs = %{provider: "some provider", uid: "some uid"}

      assert {:ok, %UserIdentity{} = user_identity} =
               UserIdentities.create_user_identity(user, valid_attrs)

      assert user_identity.provider == "some provider"
      assert user_identity.uid == "some uid"
    end

    test "create_user_identity/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               UserIdentities.create_user_identity(user, @invalid_attrs)
    end

    test "update_user_identity/2 with valid data updates the user_identity" do
      user_identity = user_identity_fixture()
      update_attrs = %{provider: "some updated provider", uid: "some updated uid"}

      assert {:ok, %UserIdentity{} = user_identity} =
               UserIdentities.update_user_identity(user_identity, update_attrs)

      assert user_identity.provider == "some updated provider"
      assert user_identity.uid == "some updated uid"
    end

    test "update_user_identity/2 with invalid data returns error changeset", %{user: user} do
      user_identity = user_identity_fixture(user)

      assert {:error, %Ecto.Changeset{}} =
               UserIdentities.update_user_identity(user_identity, @invalid_attrs)

      assert user_identity == UserIdentities.get_user_identity!(user, user_identity.id)
    end

    test "delete_user_identity/1 deletes the user_identity", %{user: user} do
      user_identity = user_identity_fixture(user)
      assert {:ok, %UserIdentity{}} = UserIdentities.delete_user_identity(user_identity)

      assert_raise Ecto.NoResultsError, fn ->
        UserIdentities.get_user_identity!(user, user_identity.id)
      end
    end

    test "change_user_identity/1 returns a user_identity changeset" do
      user_identity = user_identity_fixture()
      assert %Ecto.Changeset{} = UserIdentities.change_user_identity(user_identity)
    end
  end
end
