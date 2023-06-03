defmodule AnotherTest.UserIdentities do
  @moduledoc """
  The UserIdentities context.
  """

  import Ecto.Query, warn: false
  alias AnotherTest.Repo

  alias AnotherTest.Users
  alias AnotherTest.UserIdentities.UserIdentity

  defp generate_password do
    :crypto.strong_rand_bytes(10) |> Base.encode64()
  end

  # SCENARIOS
  # 1. Identity doesnt exist, user doesnt exist => Register account and login user
  # 2. Identity exists, user exists => Login user
  # 3. User exists, identity doesnt exist => Return an error. If user is signed in, connect the two
  # 4. Identity exists, user doesnt exist => User has changed email, look at user attached to user_identity
  def find_or_create_user(%Ueberauth.Auth{uid: uid, provider: provider, info: %{email: "" <> email}}) do
    user = Users.get_user_by_email(email)
    user_identity = get_user_identity_by_provider_and_uid(provider, uid)

    case {!is_nil(user), !is_nil(user_identity)} do
      {false, true} ->
        {:ok, user_identity.user}
      {true, true} ->
        {:ok, user}
      {true, false} ->
        {:error, user}
      {false, false} ->
        {:ok, user} = create_user_from_user_identity(email)
        create_user_identity(user, %{uid: uid, provider: provider})
        {:just_created, user}
    end
  end

  def find_or_create_user(_) do
    {:error, "Email is required to authenticate with this solution"}
  end

  defp create_user_from_user_identity(email) do
    AnotherTest.Users.register_user(%{email: email, password: generate_password()})
  end

  @doc """
  Gets a single user_identity.

  Raises `Ecto.NoResultsError` if the User identity does not exist.

  ## Examples

      iex> get_user_identity_by_provider_and_uid(:github, 123)
      %UserIdentity{}

      iex> get_user_identity_by_provider_and_uid(:github, 456)
      ** (Ecto.NoResultsError)

  """
  def get_user_identity_by_provider_and_uid(provider, uid) do
    Repo.get_by(UserIdentity, provider: provider, uid: uid)
    |> case do
      nil -> nil
      user_identity -> Repo.preload(user_identity, :user, skip_account_id: true)
    end
  end

  @doc """
  Returns the list of user_identities.

  ## Examples

      iex> list_user_identities()
      [%UserIdentity{}, ...]

  """
  def list_user_identities(user) do
    Repo.all(from u in UserIdentity, where: u.user_id == ^user.id)
  end

  @doc """
  Gets a single user_identity.

  Raises `Ecto.NoResultsError` if the User identity does not exist.

  ## Examples

      iex> get_user_identity!(123)
      %UserIdentity{}

      iex> get_user_identity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_identity!(user, id), do: Repo.get_by!(UserIdentity, id: id, user_id: user.id)

  @doc """
  Creates a user_identity.

  ## Examples

      iex> create_user_identity(%{field: value})
      {:ok, %UserIdentity{}}

      iex> create_user_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_identity(user, attrs \\ %{}) do
    %UserIdentity{}
    |> UserIdentity.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a user_identity.

  ## Examples

      iex> update_user_identity(user_identity, %{field: new_value})
      {:ok, %UserIdentity{}}

      iex> update_user_identity(user_identity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_identity(%UserIdentity{} = user_identity, attrs) do
    user_identity
    |> UserIdentity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_identity.

  ## Examples

      iex> delete_user_identity(user_identity)
      {:ok, %UserIdentity{}}

      iex> delete_user_identity(user_identity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_identity(%UserIdentity{} = user_identity) do
    Repo.delete(user_identity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_identity changes.

  ## Examples

      iex> change_user_identity(user_identity)
      %Ecto.Changeset{data: %UserIdentity{}}

  """
  def change_user_identity(%UserIdentity{} = user_identity, attrs \\ %{}) do
    UserIdentity.changeset(user_identity, attrs)
  end
end
