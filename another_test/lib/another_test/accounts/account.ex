defmodule AnotherTest.Accounts.Account do
  @moduledoc """
  The Account Schema
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :personal, :boolean, default: false

    belongs_to :created_by, AnotherTest.Users.User, foreign_key: :created_by_user_id
    has_many :memberships, AnotherTest.Accounts.Membership
    has_many :members, through: [:memberships, :member]

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :personal])
    |> validate_required([:name, :personal])
    |> unique_constraint(:personal, name: :accounts_limit_personal_index)
  end
end
