defmodule AnotherTest.Billing.Stripe.SynchronizeProducts do
  @moduledoc """
  This module is responsible for getting data from Stripe
  and storing it in the database. It can be run manually or on a schedule.
  """
  import AnotherTest.Billing.Stripe.StripeService

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Product

  defp get_all_products_from_stripe do
    {:ok, %{data: products}} = stripe_service(:list_products)
    products
  end

  def run do
    products_by_remote_id =
      Billing.list_records(Product)
      |> Enum.group_by(& &1.remote_id)

    existing_ids =
      get_all_products_from_stripe()
      |> Enum.map(fn stripe_product ->
        Billing.create_or_update(Product, stripe_product)
      end)

    products_by_remote_id
    |> Enum.reject(fn {stripe_id, _billing_product} ->
      Enum.member?(existing_ids, stripe_id)
    end)
    |> Enum.each(fn {_stripe_id, [billing_product]} ->
      Billing.delete_record(billing_product)
    end)
  end
end
