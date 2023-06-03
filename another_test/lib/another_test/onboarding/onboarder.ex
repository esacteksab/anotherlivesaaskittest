defmodule AnotherTest.Onboarding.Onboarder do
  @moduledoc """
  This represents an onboarder, a user and account that passes through the
  onboarding steps and who progress is stored in the database.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "onboarders" do
    field :data, :map
    field :step, :string
    field :completed, :boolean, default: false

    belongs_to :account, AnotherTest.Accounts.Account
    belongs_to :user, AnotherTest.Users.User

    timestamps()
  end

  @doc false
  def changeset(onboarder, attrs) do
    onboarder
    |> cast(attrs, [:step, :data, :completed])
    |> validate_required([:step])
  end
end
