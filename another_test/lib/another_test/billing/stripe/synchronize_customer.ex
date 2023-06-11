defmodule AnotherTest.Billing.Stripe.SynchronizeCustomer do
  @moduledoc """
  This module is responsible for getting data from Stripe
  and storing it in the database. It can be run manually or on a schedule.
  """
  import AnotherTest.Billing.Stripe.StripeService

  alias AnotherTest.Billing.Stripe.HandlePaymentMethods

  alias AnotherTest.Billing.Stripe.Customer

  def run(%Customer{} = customer) do
    sync_payment_method(customer)
  end

  def sync_payment_method(%{remote_id: nil} = _customer), do: nil

  def sync_payment_method(%{remote_id: remote_id} = _customer) do
    case stripe_service(:list_payment_methods, args: %{customer: remote_id, type: "card"}) do
      {:ok, %{data: [payment_method | _]}} -> HandlePaymentMethods.add_card_info(payment_method)
      {:ok, %{data: []}} -> HandlePaymentMethods.remove_card_info(%{customer: remote_id})
      _ -> nil
    end
  end
end
