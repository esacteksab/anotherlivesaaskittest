defmodule AnotherTest.Billing.Stripe.Invoice do
  @moduledoc """
  The invoice schema.
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  alias AnotherTest.EctoHelpers.Stringable
  alias AnotherTest.Billing.Stripe.Customer

  @derive {
    Flop.Schema,
    default_limit: 20,
    filterable: [:status, :subtotal, :remote_id],
    sortable: [:status, :subtotal, :remote_id]
  }
  schema "billing_invoices" do
    field :remote_id, Stringable
    field :hosted_invoice_url, :string
    field :invoice_pdf, :string
    field :status, :string
    field :subtotal, :integer

    belongs_to :customer, Customer,
      references: :remote_id,
      foreign_key: :remote_customer_id,
      type: Stringable

    timestamps()
  end

  def new, do: %__MODULE__{}

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :hosted_invoice_url,
      :invoice_pdf,
      :status,
      :remote_id,
      :subtotal,
      :remote_customer_id
    ])
    |> validate_required([:remote_id])
    |> unique_constraint(:remote_id, name: :billing_invoices_remote_id_index)
  end
end
