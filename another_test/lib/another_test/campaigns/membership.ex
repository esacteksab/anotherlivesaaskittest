defmodule AnotherTest.Campaigns.Membership do
  @moduledoc """
  The membership schema.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias AnotherTest.EctoHelpers.AtomType

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "campaign_memberships" do
    field :campaign, AtomType
    field :last_sent_at, :naive_datetime
    field :step, AtomType

    belongs_to :user, AnotherTest.Users.User

    timestamps()
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:campaign, :step, :last_sent_at])
    |> validate_required([:campaign, :step])
  end
end
