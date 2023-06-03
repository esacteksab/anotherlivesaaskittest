defmodule AnotherTest.Campaigns.Receipt do
  @moduledoc """
  The receipt schema.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias AnotherTest.EctoHelpers.AtomType

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "campaign_receipts" do
    field :campaign, AtomType
    field :step, AtomType

    belongs_to :user, AnotherTest.Users.User

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(receipt, attrs) do
    receipt
    |> cast(attrs, [:step, :campaign])
    |> validate_required([:step, :campaign])
  end
end
