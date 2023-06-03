defmodule AnotherTest.Admins.Admin do
  @moduledoc """
  The Admin schema.
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    default_limit: 20,
    filterable: [:name, :email],
    sortable: [:name, :email]
  }
  @derive {Inspect, except: [:password]}
  schema "admins" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:email, :name, :password])
    |> validate_required([:email])
    |> maybe_apply_password_change()
  end

  @doc """
  A admin changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.
  """
  def registration_changeset(admin, attrs) do
    admin
    |> cast(attrs, [:name, :email, :password])
    |> validate_email()
    |> validate_password()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, AnotherTest.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 80)
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> prepare_changes(&hash_password/1)
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    changeset
    |> put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
    |> delete_change(:password)
  end

  def maybe_apply_password_change(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset
      _ ->
        changeset
        |> validate_confirmation(:password, message: "does not match password")
        |> validate_password()
    end
  end
end
