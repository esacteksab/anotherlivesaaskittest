defmodule AnotherTest.Billing.SynchronizePlansTest do
  use AnotherTest.DataCase

  import AnotherTest.BillingFixtures

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Plan
  alias AnotherTest.Billing.Stripe.SynchronizePlans

  describe "run" do
    test "run/0 syncs plans from stripe and creates them in billing_plans" do
      assert Billing.list_records(Plan) == []

      SynchronizePlans.run()
      assert [%Plan{}] = Billing.list_records(Plan)
    end

    test "run/0 deletes plans that exists in local database but does not exists in stripe" do
      {:ok, plan} =
        Billing.create_or_update(Plan, %{
          name: "Dont exists",
          remote_id: "price_abc123def456",
          remote_product_id: unique_remote_id(),
          amount: 666,
          active: true
        })

      assert Billing.list_records(Plan) == [plan]

      SynchronizePlans.run()
      assert Billing.get_record(Plan, plan.remote_id) == nil
    end
  end
end
