defmodule AnotherTest.Billing.Stripe.Product do
  @moduledoc """
  The product schema.
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  alias AnotherTest.EctoHelpers.Stringable

  @derive {
    Flop.Schema,
    default_limit: 20,
    filterable: [:active, :name, :local_name, :remote_id],
    sortable: [:active, :name, :local_name, :remote_id]
  }
  schema "billing_products" do
    field :active, :boolean
    field :description, :string
    field :local_description, :string
    field :local_name, :string
    field :name, :string
    field :remote_id, Stringable

    timestamps()
  end

  def new, do: %__MODULE__{}

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:remote_id, :active, :description, :local_description, :local_name, :name])
    |> validate_required([:remote_id])
    |> unique_constraint(:remote_id, name: :billing_products_remote_id_index)
  end
end
