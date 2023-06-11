defmodule AnotherTest.Billing.Stripe.Plan do
  @moduledoc """
  The plan schema.
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  alias AnotherTest.EctoHelpers.Stringable
  alias AnotherTest.Billing.Stripe.Product

  @derive {
    Flop.Schema,
    default_limit: 20,
    filterable: [:active, :amount, :name, :remote_id],
    sortable: [:active, :amount, :name, :remote_id]
  }
  schema "billing_plans" do
    field :active, :boolean
    field :amount, :integer
    field :currency, :string
    field :interval, :string
    field :interval_count, :integer
    field :name, :string
    field :local_name, :string
    field :remote_id, Stringable
    field :trial_period_days, :integer
    field :usage_type, :string

    belongs_to :product, Product,
      references: :remote_id,
      foreign_key: :remote_product_id,
      type: Stringable

    timestamps()
  end

  def new, do: %__MODULE__{}

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [
      :active,
      :amount,
      :currency,
      :interval,
      :interval_count,
      :name,
      :local_name,
      :remote_id,
      :remote_product_id,
      :trial_period_days,
      :usage_type
    ])
    |> validate_required([:remote_id])
    |> unique_constraint(:remote_id, name: :billing_plans_remote_id_index)
  end
end
