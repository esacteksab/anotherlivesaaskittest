defmodule AnotherTest.Billing.Stripe.HandlePaymentMethods do
  @moduledoc """
  This module is reponsible for setting and removing the card data on the
  billing customer. This will be called from the webhook processor
  """
  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Customer

  def add_card_info(%{customer: nil}), do: nil

  def add_card_info(%{customer: remote_id} = payment_method) do
    if customer = Billing.get_record(Customer, remote_id) do
      Billing.update_customer(customer, payment_method)
    end
  end

  def remove_card_info(%{customer: nil}), do: nil

  def remove_card_info(%{customer: remote_id}) do
    if customer = Billing.get_record(Customer, remote_id) do
      Billing.update_customer(customer, %{
        card_brand: nil,
        card_last4: nil,
        card_exp_year: nil,
        card_exp_month: nil
      })
    end
  end
end
