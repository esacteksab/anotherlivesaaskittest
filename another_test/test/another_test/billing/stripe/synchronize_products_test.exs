defmodule AnotherTest.Billing.SynchronizeProductsTest do
  use AnotherTest.DataCase

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Product
  alias AnotherTest.Billing.Stripe.SynchronizeProducts

  describe "run" do
    test "run/0 syncs products from stripe and creates them in billing_products" do
      assert Billing.list_records(Product) == []

      SynchronizeProducts.run()
      assert [%Product{}] = Billing.list_records(Product)
    end

    test "run/0 deletes products that exists in local database but does not exists in stripe" do
      {:ok, product} =
        Billing.create_or_update(Product, %{
          active: true,
          name: "Dont exists",
          remote_id: "prod_abc123def456"
        })

      assert Billing.list_records(Product) == [product]

      SynchronizeProducts.run()
      assert Billing.get_record(Product, product.remote_id) == nil
    end
  end
end
