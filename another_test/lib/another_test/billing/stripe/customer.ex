defmodule AnotherTest.Billing.Stripe.Customer do
  @moduledoc """
  The customer schema.
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  alias AnotherTest.EctoHelpers.Stringable
  alias AnotherTest.Billing.Stripe.Subscription

  @derive {
    Flop.Schema,
    default_limit: 20,
    filterable: [:email, :billing_email, :remote_id],
    sortable: [:email, :billing_email, :remote_id]
  }
  schema "users" do
    field :email, :string
    field :billing_email, :string
    field :card_brand, :string
    field :card_exp_month, :integer
    field :card_exp_year, :integer
    field :card_last4, :string
    field :remote_id, Stringable

    has_many :subscriptions, Subscription,
      references: :remote_id,
      foreign_key: :remote_customer_id

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :billing_email,
      :card_brand,
      :card_exp_month,
      :card_exp_year,
      :card_last4,
      :remote_id
    ])
    |> validate_required([:remote_id])
    |> unique_constraint(:remote_id, name: :users_remote_id_index)
  end
end
