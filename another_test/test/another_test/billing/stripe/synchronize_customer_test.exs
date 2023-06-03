defmodule AnotherTest.Billing.SynchronizeCustomerTest do
  use AnotherTest.DataCase, async: true

  import AnotherTest.BillingFixtures

  alias AnotherTest.Billing.Stripe.SynchronizeCustomer

  describe "run" do
    test "run/1 syncs payment method from stripe and stores it on the customer" do
      customer = customer_fixture()

      refute customer.card_last4 == "4242"
      assert {:ok, customer} = SynchronizeCustomer.run(customer)
      assert customer.card_last4 == "4242"
    end
  end
end
