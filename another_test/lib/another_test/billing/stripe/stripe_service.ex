defmodule AnotherTest.Billing.Stripe.StripeService do
  @moduledoc """
  This module is an abstraction so in tests this mock-stripe module can be used instead
  of hitting production Stripe.

      import AnotherTest.Billing.Stripe.StripeService
  """
  defp test?, do: Application.get_env(:another_test, :env) == :test

  def stripe_service(name), do: stripe_service(name, [])

  def stripe_service(:list_plans, opts) do
    if test?() do
      stripe_id = Keyword.get(opts, :remote_id) || "price_#{token()}"

      {:ok,
       %Stripe.List{
         data: [
           %Stripe.Plan{
             active: true,
             amount: 9900,
             amount_decimal: "9900",
             currency: "usd",
             id: stripe_id,
             interval: "year",
             interval_count: 1,
             nickname: "One year membership",
             object: "plan",
             product: "prod_I2TE8siyANz84p",
             usage_type: "licensed"
           }
         ],
         has_more: false,
         object: "list",
         total_count: nil,
         url: "/v1/plans"
       }}
    else
      Stripe.Plan.list()
    end
  end

  def stripe_service(:list_products, opts) do
    if test?() do
      stripe_id = Keyword.get(opts, :remote_id) || "prod_#{token()}"

      {:ok,
       %Stripe.List{
         data: [
           %Stripe.Product{
             created: 1_600_353_622,
             id: stripe_id,
             name: "Premium Plan",
             object: "product",
             updated: 1_600_798_919,
             active: true
           }
         ],
         has_more: false,
         object: "list",
         total_count: nil,
         url: "/v1/products"
       }}
    else
      Stripe.Product.list()
    end
  end

  def stripe_service(:list_subscriptions, opts) do
    args = Keyword.get(opts, :args, %{})
    test_data = Keyword.get(opts, :test_data, [])

    if test?() do
      {:ok, %{data: test_data}}
    else
      Stripe.Subscription.list(args)
    end
  end

  def stripe_service(:list_payment_methods, opts) do
    args = Keyword.get(opts, :args, %{})

    if test?() do
      case args do
        %{customer: "" <> customer_stripe_id} ->
          payment_method = %Stripe.PaymentMethod{
            card: %{
              brand: "visa",
              exp_month: 5,
              exp_year: 2035,
              last4: "4242"
            },
            customer: customer_stripe_id,
            type: "card"
          }

          {:ok, %{data: [payment_method]}}

        _ ->
          {:ok, %{data: []}}
      end
    else
      Stripe.PaymentMethod.list(args)
    end
  end

  def stripe_service(:webhook_construct_event, opts) do
    raw_body = Keyword.get(opts, :raw_body, %{})
    stripe_signature = Keyword.get(opts, :stripe_signature)
    webhook_signing_key = Keyword.get(opts, :webhook_signing_key)

    if test?() do
      construct_webhook_event(raw_body, stripe_signature, webhook_signing_key)
    else
      Stripe.Webhook.construct_event(raw_body, stripe_signature, webhook_signing_key)
    end
  end

  def stripe_service(:create_customer, opts) do
    args = Keyword.get(opts, :args, %{})

    if test?() do
      stripe_id = Keyword.get(opts, :remote_id) || "cus_#{token()}"

      {:ok,
       %Stripe.Customer{
         created: 1_600_892_385,
         email: "andreas@codered.se",
         id: stripe_id,
         name: "Andreas Eriksson",
         object: "customer"
       }
       |> Map.merge(args)}
    else
      Stripe.Customer.create(args)
    end
  end

  defp token do
    :crypto.strong_rand_bytes(12) |> Base.encode16(case: :lower)
  end

  defp construct_webhook_event(
         _raw_body,
         "wrong_signature" = _stripe_signature,
         _webhook_signing_key
       ) do
    send(self(), {:ok, "invalid_webhook"})

    {:error, "Signature has expired"}
  end

  defp construct_webhook_event(_raw_body, _stripe_signature, _webhook_signing_key) do
    send(self(), {:ok, "valid_webhook"})

    {:ok,
     %Stripe.Event{
       id: "evt_#{token()}",
       object: "event",
       request: %{
         id: "req_#{token()}",
         idempotency_key: token()
       },
       type: "payment_intent.created"
     }}
  end
end
