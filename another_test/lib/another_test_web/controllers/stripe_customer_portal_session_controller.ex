defmodule AnotherTestWeb.StripeCustomerPortalSession do
  @moduledoc """
  This Controller is used when the customer accessing the Stripe Customer Portal.
  Make sure you have activated the Stripe Customer Portal in your Stripe settings.
  """
  use AnotherTestWeb, :controller

  alias AnotherTest.Billing

  def create(conn, _params) do
    customer = Billing.get_billing_customer_for_user(conn.assigns.current_user)

    case Stripe.BillingPortal.Session.create(%{
      customer: customer.stripe_id,
      return_url: url(~p"/billing?sync=true")
    }) do
      {:ok, session} -> redirect(conn, external: session.url)
      _ -> redirect(conn, to: ~p"/billing")
    end
  end
end
