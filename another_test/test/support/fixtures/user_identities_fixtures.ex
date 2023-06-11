defmodule AnotherTest.UserIdentitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AnotherTest.UserIdentities` context.
  """

  import AnotherTest.UsersFixtures

  alias AnotherTest.UserIdentities
  alias AnotherTest.Users.User

  def ueberauth_response(attr \\ %{}) do
    %Ueberauth.Auth{
      credentials: %Ueberauth.Auth.Credentials{},
      info: %Ueberauth.Auth.Info{
        birthday: nil,
        email: Map.get(attr, :email, unique_user_email()),
        first_name: nil,
        image: "https://avatars.githubusercontent.com/u/897748?v=4",
        last_name: nil,
        name: "John Doe",
        nickname: "John D"
      },
      provider: :github,
      strategy: Ueberauth.Strategy.Github,
      uid: 897_748
    }
  end

  @doc """
  Generate a user_identity.
  """
  def user_identity_fixture(), do: user_identity_fixture(%{})
  def user_identity_fixture(%User{} = user), do: user_identity_fixture(user, %{})

  def user_identity_fixture(attrs) do
    user = user_fixture()
    user_identity_fixture(user, attrs)
  end

  def user_identity_fixture(%User{} = user, attrs) do
    attrs =
      Enum.into(attrs, %{
        provider: "some provider",
        uid: "some uid"
      })

    {:ok, user_identity} = AnotherTest.UserIdentities.create_user_identity(user, attrs)

    UserIdentities.get_user_identity!(user, user_identity.id)
  end
end
