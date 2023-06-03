defmodule AnotherTest.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AnotherTest.Billing` context.
  """

  import AnotherTest.UsersFixtures

  alias AnotherTest.Users.User
  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Customer
  alias AnotherTest.Billing.Stripe.Product
  alias AnotherTest.Billing.Stripe.Plan
  alias AnotherTest.Billing.Stripe.Subscription
  alias AnotherTest.Billing.Stripe.Invoice

  def unique_remote_id(prefix \\ "foo"), do: "#{prefix}_#{:crypto.strong_rand_bytes(12) |> Base.encode16(case: :lower)}"

  def stripe_customer_data(attrs \\ %{}) do
    %Stripe.Customer{
      id: unique_remote_id("cus"),
      created: 1_600_892_385,
      email: "john@example.com",
      name: "John Doe",
      object: "customer"
    }
    |> Map.merge(attrs)
  end

  def stripe_product_data(attrs \\ %{}) do
    %Stripe.Product{
      created: 1_600_353_622,
      id: unique_remote_id("prod"),
      name: "Premium Plan",
      object: "product",
      updated: 1_600_798_919,
      active: true
    }
    |> Map.merge(attrs)
  end

  def stripe_plan_data(attrs \\ %{}) do
    %Stripe.Plan{
      id: unique_remote_id("price"),
      product: unique_remote_id("prod"),
      object: "plan",
      active: true,
      amount: 1400,
      amount_decimal: "1400",
      billing_scheme: "per_unit",
      created: 1_673_595_174,
      currency: "usd",
      deleted: nil,
      interval: "month",
      interval_count: 1,
    }
    |> Map.merge(attrs)
  end

  def stripe_subscription_data(attrs \\ %{}) do
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
      plan: stripe_plan_data(),
      start_date: 1_682_076_599,
      status: "active",
      trial_end: nil,
      trial_start: nil
    }
    |> Map.merge(attrs)
  end

  def stripe_invoice_data(attrs) do
    %Stripe.Invoice{
      id: unique_remote_id("in"),
      customer: unique_remote_id("cus"),
      currency: "usd",
      subtotal: 900,
      status: "paid",
      invoice_pdf:
        "https://pay.stripe.com/invoice/#{unique_remote_id("acct")}/#{unique_remote_id("test")}/pdf",
      hosted_invoice_url:
        "https://invoice.stripe.com/i/#{unique_remote_id("acct")}/#{unique_remote_id("test")}"
    }
    |> Map.merge(attrs)
  end

  def stripe_payment_method_data(attrs) do
    %Stripe.PaymentMethod{
      id: unique_remote_id("pm"),
      card: %{
        brand: "visa",
        exp_month: 5,
        exp_year: 2035,
        last4: "4242",
      },
      customer: unique_remote_id("cus"),
      type: "card"
    }
    |> Map.merge(attrs)
  end

  @doc """
  Generate a customer.
  """
  def customer_fixture(), do: customer_fixture(%{})
  def customer_fixture(%User{} = user), do: customer_fixture(user, %{})

  def customer_fixture(attrs) do
    user = user_fixture()
    customer_fixture(user, attrs)
  end

  def customer_fixture(user, attrs) do
    customer = Billing.get_billing_customer_for_user(user)

    attrs = stripe_customer_data(attrs)
    {:ok, product} = Billing.update_customer(customer, attrs)
    product
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    attrs = stripe_product_data(attrs)
    {:ok, product} = Billing.create_or_update(Product, attrs)
    product
  end

  @doc """
  Generate a plan.
  """
  def plan_fixture(attrs \\ %{}) do
    attrs = stripe_plan_data(attrs)
    {:ok, plan} = Billing.create_or_update(Plan, attrs)
    plan
  end

  @doc """
  Generate a subscription.
  """
  def subscription_fixture(attrs \\ %{}) do
    attrs = stripe_subscription_data(attrs)
    {:ok, subscription} = Billing.create_or_update(Subscription, attrs)
    subscription
  end

  @doc """
  Generate an active subscription.
  """
  def active_subscription_fixture() do
    active_subscription_fixture(customer_fixture())
  end

  def active_subscription_fixture(%Customer{} = customer) do
    time_in_seconds =
      Date.utc_today()
      |> Date.add(1)
      |> Date.diff(~D[1970-01-01])

    subscription_fixture(%{
      customer: customer.remote_id,
      status: "active",
      current_period_end_at: time_in_seconds,
      canceled_at: nil,
      cancel_at: nil
    })
  end

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    attrs = stripe_invoice_data(attrs)
    {:ok, invoice} = Billing.create_or_update(Invoice, attrs)
    invoice
  end
end
