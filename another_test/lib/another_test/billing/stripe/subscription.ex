defmodule AnotherTest.Billing.Stripe.Subscription do
  @moduledoc """
  The subscription schema.
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  alias AnotherTest.EctoHelpers.Stringable
  alias AnotherTest.Billing.Stripe.Customer
  alias AnotherTest.Billing.Stripe.Plan

  @derive {
    Flop.Schema,
    default_limit: 20,
    filterable: [:status, :remote_id],
    sortable: [:status, :remote_id]
  }
  schema "billing_subscriptions" do
    field :remote_id, Stringable
    field :cancel_at, :naive_datetime
    field :canceled_at, :naive_datetime
    field :current_period_end_at, :naive_datetime
    field :current_period_start, :naive_datetime
    field :status, :string

    belongs_to :customer, Customer, references: :remote_id, foreign_key: :remote_customer_id, type: Stringable
    belongs_to :plan, Plan, references: :remote_id, foreign_key: :remote_plan_id, type: Stringable

    timestamps()
  end

  def new, do: %__MODULE__{}

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:status, :remote_id, :remote_plan_id, :remote_customer_id])
    |> cast_convert_to_naive_datetime(attrs, [:cancel_at, :canceled_at, :current_period_end_at, :current_period_start])
    |> validate_required([:remote_id])
    |> unique_constraint(:remote_id, name: :billing_subscriptions_remote_id_index)
  end

  defp cast_convert_to_naive_datetime(changeset, attrs, fields) do
    [fields]
    |> List.flatten()
    |> Enum.reduce(changeset, fn field, memo ->
      if value = (Map.get(attrs, field) || Map.get(attrs, "#{field}")) do
        put_change(memo, field, NaiveDateTime.add(~N[1970-01-01 00:00:00], value))
      else
        memo
      end
    end)
  end
end
