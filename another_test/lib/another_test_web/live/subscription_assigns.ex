defmodule AnotherTestWeb.Live.SubscriptionAssigns do
  @moduledoc """
  Assigns billing customer and current subscription
  """

  import Phoenix.Component
  import Phoenix.LiveView

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Subscription

  def on_mount(:billing_customer, _params, _session, %{assigns: %{current_account: account}} = socket) do
    billing_customer =
      case socket.assigns do
        %{billing_customer: %{} = billing_customer} -> billing_customer
        _ -> Billing.get_billing_customer_for_account(account)
      end

    {:cont, assign(socket, :billing_customer, billing_customer)}
  end

  def on_mount(:billing_customer, _params, _session, socket) do
    {:cont, assign(socket, :billing_customer, nil)}
  end

  def on_mount(:current_subscription, _params, _session, socket) do
    current_subscription =
      case socket.assigns do
        %{current_subscription: %{} = current_subscription} -> current_subscription
        _ -> Billing.get_active_subscription_for_account(socket.assigns.account)
      end

    {:cont, assign(socket, :current_subscription, current_subscription)}
  end

  def on_mount(:require_subscription, _params, _session,  %{assigns: %{current_subscription: %Subscription{}}} = socket) do
    {:cont, socket}
  end

  def on_mount(:require_subscription, _params, _session, socket) do
    {
      :halt,
      socket
      |> put_flash(:info, "A subscription is required to access the page")
      |> redirect(to: "/") # Change the path to what suits your app best
    }
  end

  def on_mount(:refute_subscription, _params, _session, %{assigns: %{current_subscription: %Subscription{}}} = socket) do
    {
      :halt,
      socket
      |> put_flash(:info, "You already have an active subscription")
      |> redirect(to: "/") # Change the path to what suits your app best
    }
  end

  def on_mount(:refute_subscription, _params, _session, socket) do
    {:cont, socket}
  end
end
