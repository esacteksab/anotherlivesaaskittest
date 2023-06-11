defmodule AnotherTestWeb.StripeReturnController do
  @moduledoc """
  This Controller is used when the customer is treurning from Stripe after have used
  Checkout or Customer Portal. Url is /return_from_stripe
  """
  use AnotherTestWeb, :controller

  import AnotherTest.Billing.Stripe.StripeService
  import AnotherTest.Billing.Helpers, only: [decode_token: 1]

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Customer
  alias AnotherTest.Billing.Stripe.Subscription

  def new(conn, %{"t" => "success", "bp" => encoded_token} = _params) do
    case decode_token(encoded_token) do
      {:ok, customer_stripe_id} ->
        user_return_to = get_session(conn, :user_return_to) || ~p"/billing"
        customer = Billing.get_record(Customer, customer_stripe_id)

        case stripe_service(:list_subscriptions,
               args: %{customer: customer.remote_id, status: "active"}
             ) do
          {:ok, %Stripe.List{data: [stripe_subscription | _]}} ->
            Billing.create_or_update(Subscription, stripe_subscription)

          _ ->
            nil
        end

        conn
        |> put_flash(:success, "The subscription signup was completed")
        |> redirect(to: user_return_to)

      _ ->
        render(conn, "error.html")
    end
  end

  def new(conn, %{"t" => "cancel", "bp" => encoded_token} = _params) do
    case decode_token(encoded_token) do
      {:ok, _token} ->
        user_return_to = get_session(conn, :user_return_to) || ~p"/billing"

        conn
        |> put_flash(:info, "The subscription signup was cancelled")
        |> redirect(to: user_return_to)

      _ ->
        render(conn, "error.html")
    end
  end
end
