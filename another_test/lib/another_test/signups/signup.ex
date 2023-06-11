defmodule AnotherTest.Signups.Signup do
  @moduledoc """
  The Signup schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "signups" do
    field :email, :string
    field :name, :string
    field :phone, :string
    field :signed_of_at, :naive_datetime
    field :topic, :string

    timestamps()
  end

  @doc false
  def changeset(signup, attrs) do
    signup
    |> cast(attrs, [:email, :name, :phone, :topic, :signed_of_at])
    |> validate_required([:email, :topic])
    |> validate_format(:email, ~r/@/)
    |> downcase_email()
    |> unique_constraint(:email, name: :signups_email_topic_index)
  end

  defp downcase_email(changeset) do
    case get_change(changeset, :email) do
      "" <> email ->
        email = String.downcase(email)
        put_change(changeset, :email, email)

      _ ->
        changeset
    end
  end
end
