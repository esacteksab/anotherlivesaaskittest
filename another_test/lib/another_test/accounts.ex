defmodule AnotherTest.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias AnotherTest.Repo

  alias AnotherTest.Accounts.Account
  alias AnotherTest.Accounts.Membership
  alias AnotherTest.Accounts.Member
  alias AnotherTest.Accounts.Invitation

  def paginate_accounts(params \\ %{}) do
    Flop.validate_and_run(Account, params, for: Account)
  end

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(user, attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:created_by, user)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  @doc """
  Returns members associations for an account.

  ## Examples

      iex> with_members(account)
      %Account{members: [...]}

  """
  def with_members(account_or_accounts) do
    account_or_accounts
    |> Repo.preload(:members, skip_account_id: true)
  end

  @doc """
  Returns true if a user has access to an account.

  ## Examples

      iex> can_be_accessed_by_a_user?(account, user)
      true

  """
  def can_be_accessed_by_a_user?(account, user) do
    account
    |> with_members()
    |> Map.get(:members, [])
    |> Enum.map(& &1.id)
    |> Enum.member?(user.id)
  end

  @doc """
  Returns the list of memberships.

  ## Examples

      iex> list_memberships()
      [%Membership{}, ...]

  """
  def list_memberships(account) do
    from(m in Membership,
      join: mm in assoc(m, :member)
    )
    |> Repo.all(account_id: account.id)
  end

  @doc """
  Gets a single membership.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(123)
      %Membership{}

      iex> get_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(account, id), do: Repo.get!(Membership, id, account_id: account.id)

  @doc """
  Creates a membership.

  ## Examples

      iex> create_membership(%{field: value})
      {:ok, %Membership{}}

      iex> create_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(account, user, attrs \\ %{}) do
    # Transform the user to a member
    member = Repo.get!(Member, user.id)

    %Membership{}
    |> Membership.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Ecto.Changeset.put_assoc(:member, member)
    |> Repo.insert()
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(membership)
      {:ok, %Membership{}}

      iex> delete_membership(membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end

  @doc """
  Returns the list of invitations.

  ## Examples

      iex> list_invitations(account)
      [%Invitation{}, ...]

  """
  def list_invitations(account) do
    from(m in Invitation,
      order_by: [:inserted_at]
    )
    |> Repo.all(account_id: account.id)
  end

  @doc """
  Returns the list of invitations for a user.

  ## Examples

      iex> list_invitations_for_user(account)
      [%Invitation{}, ...]

  """
  def list_invitations_for_user(user) do
    from(i in Invitation,
      where: i.email == ^user.email,
      where: is_nil(i.accepted_at),
      order_by: [:inserted_at],
      preload: [:account, :invited_by]
    )
    |> Repo.all(skip_account_id: true)
  end

  @doc """
  Gets a single invitation.

  Raises `Ecto.NoResultsError` if the Invitation does not exist.

  ## Examples

      iex> get_invitation!(account, 123)
      %Invitation{}

      iex> get_invitation!(account, 456)
      ** (Ecto.NoResultsError)

  """
  def get_invitation!(account, id), do: Repo.get!(Invitation, id, account_id: account.id)

  @doc """
  Creates a invitation.

  ## Examples

      iex> create_invitation(%{field: value})
      {:ok, %Invitation{}}

      iex> create_invitation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invitation(account, user, attrs \\ %{}) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Ecto.Changeset.put_assoc(:invited_by, user)
    |> Repo.insert()
    |> invite_member()
  end

  @doc """
  Updates a invitation.

  ## Examples

      iex> update_invitation(invitation, %{field: new_value})
      {:ok, %Invitation{}}

      iex> update_invitation(invitation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invitation(%Invitation{} = invitation, attrs) do
    invitation
    |> Invitation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invitation.

  ## Examples

      iex> delete_invitation(invitation)
      {:ok, %Invitation{}}

      iex> delete_invitation(invitation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invitation changes.

  ## Examples

      iex> change_invitation(invitation)
      %Ecto.Changeset{data: %Invitation{}}

  """
  def change_invitation(%Invitation{} = invitation, attrs \\ %{}) do
    Invitation.changeset(invitation, attrs)
  end

  use Phoenix.VerifiedRoutes, endpoint: AnotherTestWeb.Endpoint, router: AnotherTestWeb.Router
  alias AnotherTest.Mailer
  alias AnotherTest.Accounts.InvitationNotifier

  @doc """
  Sends an email to the invited user with invitation instructions.
  After the user is created and/or signed in, the user will be prompted to me a member of the team.
  """
  def invite_member({:ok, %{email: email} = _invitation} = result) do
    url = url(~p"/users/log_in")

    InvitationNotifier.invite_user_email(%{email: email, url: url})
    |> Mailer.deliver()

    result
  end

  def invite_member(result), do: result
end
