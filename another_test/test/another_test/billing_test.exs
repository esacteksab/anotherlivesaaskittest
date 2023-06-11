defmodule AnotherTest.BillingTest do
  use AnotherTest.DataCase, async: true

  import AnotherTest.UsersFixtures
  import AnotherTest.AccountsFixtures
  import AnotherTest.BillingFixtures

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Product
  alias AnotherTest.Billing.Stripe.Plan
  alias AnotherTest.Billing.Stripe.Subscription
  alias AnotherTest.Billing.Stripe.Invoice

  describe "list_records/1" do
    test "list_records/1 - Product list all products" do
      product = product_fixture()
      assert Billing.list_records(Product) == [product]
    end

    test "list_records/1 - Plan list all plans" do
      plan = plan_fixture()
      assert Billing.list_records(Plan) == [plan]
    end

    test "list_records/1 - Subscription list all subscriptions" do
      subscription = subscription_fixture()
      assert Billing.list_records(Subscription) == [subscription]
    end

    test "list_records/1 - Invoice list all invoices" do
      invoice = invoice_fixture()
      assert Billing.list_records(Invoice) == [invoice]
    end
  end

  describe "get_record/2" do
    test "get_record/2 - Product returns one product" do
      product = product_fixture()
      assert Billing.get_record(Product, product.remote_id) == product
    end

    test "get_record/2 - Plan returns one plan" do
      plan = plan_fixture()
      assert Billing.get_record(Plan, plan.remote_id) == plan
    end

    test "get_record/2 - Subscription returns one subscription" do
      subscription = subscription_fixture()
      assert Billing.get_record(Subscription, subscription.remote_id) == subscription
    end

    test "get_record/2 - Invoice returns one invoice" do
      invoice = invoice_fixture()
      assert Billing.get_record(Invoice, invoice.remote_id) == invoice
    end
  end

  describe "create_or_update/2" do
    test "create_or_update/2 - Product when a new product" do
      attrs = stripe_product_data(%{name: "Awesome Product"})

      assert {:ok, product} = Billing.create_or_update(Product, attrs)
      assert product.name == "Awesome Product"
      assert product.active == true
    end

    test "create_or_update/2 - Product when updating a product" do
      remote_id = unique_remote_id("prod")
      attrs = stripe_product_data(%{id: remote_id, name: "Awesome Product"})

      assert {:ok, product} = Billing.create_or_update(Product, attrs)
      assert product.name == "Awesome Product"
      assert product.remote_id == remote_id

      update_attrs = stripe_product_data(%{id: remote_id, name: "Updated Product"})

      assert {:ok, _product} = Billing.create_or_update(Product, update_attrs)

      updated_product = Billing.get_record(Product, remote_id)
      assert updated_product.name == "Updated Product"
    end

    test "create_or_update/2 - Plan when a new plan" do
      attrs = stripe_plan_data(%{name: "Awesome Plan"})

      assert {:ok, plan} = Billing.create_or_update(Plan, attrs)
      assert plan.name == "Awesome Plan"
      assert plan.active == true
    end

    test "create_or_update/2 - Plan when updating a plan" do
      remote_id = unique_remote_id("prod")
      attrs = stripe_plan_data(%{id: remote_id, name: "Awesome Plan"})

      assert {:ok, plan} = Billing.create_or_update(Plan, attrs)
      assert plan.name == "Awesome Plan"
      assert plan.remote_id == remote_id

      update_attrs = stripe_plan_data(%{id: remote_id, name: "Updated Plan"})

      assert {:ok, _plan} = Billing.create_or_update(Plan, update_attrs)

      updated_plan = Billing.get_record(Plan, remote_id)
      assert updated_plan.name == "Updated Plan"
    end

    test "create_or_update/2 - Subscription when a new subscription" do
      attrs = stripe_subscription_data(%{status: "active", current_period_start: 1_682_076_598})

      assert {:ok, subscription} = Billing.create_or_update(Subscription, attrs)
      assert subscription.status == "active"
      assert subscription.current_period_start == ~N[2023-04-21 11:29:58]
    end

    test "create_or_update/2 - Subscription when updating a subscription" do
      remote_id = unique_remote_id("sub")

      attrs =
        stripe_subscription_data(%{
          id: remote_id,
          status: "active",
          current_period_start: 1_682_076_598
        })

      assert {:ok, subscription} = Billing.create_or_update(Subscription, attrs)
      assert subscription.remote_id == remote_id
      assert subscription.status == "active"
      assert subscription.current_period_start == ~N[2023-04-21 11:29:58]
      assert subscription.canceled_at == nil

      update_attrs =
        stripe_subscription_data(%{id: remote_id, status: "canceled", canceled_at: 1_684_668_099})

      assert {:ok, _subscription} = Billing.create_or_update(Subscription, update_attrs)

      updated_subscription = Billing.get_record(Subscription, remote_id)
      assert updated_subscription.status == "canceled"
      assert updated_subscription.canceled_at == ~N[2023-05-21 11:21:39]
    end

    test "create_or_update/2 - Invoice when a new invoice" do
      attrs = stripe_invoice_data(%{subtotal: 500})

      assert {:ok, invoice} = Billing.create_or_update(Invoice, attrs)
      assert invoice.subtotal == 500
      assert invoice.invoice_pdf =~ "pdf"
    end
  end

  describe "delete_record/1" do
    test "delete_record/1 - Product deletes the product" do
      product = product_fixture()
      Billing.delete_record(product)
      assert Billing.get_record(Product, product.remote_id) == nil
    end

    test "delete_record/1 - Plan deletes the plan" do
      plan = plan_fixture()
      Billing.delete_record(plan)
      assert Billing.get_record(Plan, plan.remote_id) == nil
    end
  end

  describe "customers" do
    test "get_billing_customer_for_account/1 returns the customer that is assigned to be the billing customer" do
      user = user_fixture()
      customer = customer_fixture(user)
      account = account_fixture()
      membership_fixture(account, user, %{billing_customer: true})
      assert Billing.get_billing_customer_for_account(account) == customer
    end

    test "get_billing_customer_for_user/1 returns the customer that corresponds to the user" do
      user = user_fixture()
      customer = customer_fixture(user)
      assert Billing.get_billing_customer_for_user(user) == customer
    end
  end

  describe "subscriptions" do
    test "paginate_subscriptions/1 returns paginated list of subscriptions" do
      for _ <- 1..25 do
        subscription_fixture()
      end

      {:ok, {subscriptions, meta}} = Billing.paginate_subscriptions(%{})

      assert length(subscriptions) == 20
      assert meta.current_page == 1
      assert meta.page_size == 20
      assert meta.total_pages == 2
      assert meta.total_count == 25
    end

    test "get_active_subscription_for_customer/1 returns an active subscription for a customer" do
      customer = customer_fixture()
      active_subscription_fixture(customer)
      assert %Subscription{} = Billing.get_active_subscription_for_customer(customer)
    end

    test "get_active_subscription_for_customer/1 returns nil for a customer dont have an active subscription" do
      customer = customer_fixture()
      assert Billing.get_active_subscription_for_customer(customer) == nil
    end
  end
end
