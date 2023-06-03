defmodule AnotherTest.Billing.Stripe.SynchronizePlans do
  @moduledoc """
  This module is responsible for getting data from Stripe
  and storing it in the database. It can be run manually or on a schedule.
  """
  import AnotherTest.Billing.Stripe.StripeService

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Plan

  defp get_all_plans_from_stripe do
    {:ok, %{data: plans}} = stripe_service(:list_plans)
    plans
  end

  def run do
    plans_by_remote_id =
      Billing.list_records(Plan)
      |> Enum.group_by(& &1.remote_id)

    existing_ids =
      get_all_plans_from_stripe()
      |> Enum.map(fn stripe_plan ->
        Billing.create_or_update(Plan, stripe_plan)
      end)

    plans_by_remote_id
    |> Enum.reject(fn {stripe_id, _billing_plan} ->
      Enum.member?(existing_ids, stripe_id)
    end)
    |> Enum.each(fn {_stripe_id, [billing_plan]} ->
      Billing.delete_record(billing_plan)
    end)
  end
end
