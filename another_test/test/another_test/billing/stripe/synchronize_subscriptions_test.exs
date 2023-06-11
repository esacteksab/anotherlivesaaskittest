defmodule AnotherTest.Billing.SynchronizeSubscriptionsTest do
  use AnotherTest.DataCase, async: true

  import AnotherTest.BillingFixtures

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Plan
  alias AnotherTest.Billing.Stripe.Subscription
  alias AnotherTest.Billing.Stripe.SynchronizeSubscriptions

  describe "run" do
    test "run/0 syncs subscriptions from stripe and creates them in billing_subscriptions" do
      result = SynchronizeSubscriptions.run(test_data: incoming_subscriptions())

      assert [{:ok, %Subscription{} = subscription}] = result
      assert subscription.status == "active"
      assert subscription.current_period_start == ~N[2023-04-21 11:29:59]
      assert subscription.current_period_end_at == ~N[2023-05-21 11:29:59]

      plan = Billing.get_record(Plan, subscription.remote_plan_id)
      assert plan.amount == 1400
      assert plan.interval == "month"
    end
  end

  defp incoming_subscriptions do
    [
      %Stripe.Subscription{
        id: unique_remote_id("sub"),
        object: "subscription",
        cancel_at: nil,
        cancel_at_period_end: false,
        canceled_at: nil,
        currency: "usd",
        created: 1_682_076_599,
        current_period_end: 1_684_668_599,
        current_period_start: 1_682_076_599,
        customer: unique_remote_id("cus"),
        default_payment_method: unique_remote_id("pm"),
        ended_at: nil,
        latest_invoice: unique_remote_id("in"),
        plan: %Stripe.Plan{
          id: unique_remote_id("price"),
          object: "plan",
          active: true,
          product: unique_remote_id("prod"),
          amount: 1400,
          amount_decimal: "1400",
          billing_scheme: "per_unit",
          created: 1_673_595_174,
          currency: "usd",
          deleted: nil,
          interval: "month",
          interval_count: 1
        },
        start_date: 1_682_076_599,
        status: "active"
      }
    ]
  end
end
