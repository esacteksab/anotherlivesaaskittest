defmodule AnotherTestWeb.SubscriptionLive.New do
  @moduledoc """
  The Start Subscription page. This Module requires that current_user
  and current_account is set before.
  """
  use AnotherTestWeb, :live_view

  import AnotherTest.Billing.Helpers, only: [encode_token: 1]
  alias AnotherTest.Billing

  on_mount {AnotherTestWeb.Live.SubscriptionAssigns, :billing_customer}

  @impl true
  def mount(_params, _session, socket) do
    # Check if the Stripe Api Key is set.
    stripe_not_setup = is_nil(Application.get_env(:stripity_stripe, :api_key))
    plans = list_plans()

    {
      :ok,
      socket
      |> assign(:stripe_not_setup, stripe_not_setup)
      |> assign(:plans, plans)
      |> assign(:chosen_plan_id, nil)
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("choose-plan", %{"id" => id}, socket) do
    {:noreply, assign(socket, :chosen_plan_id, id)}
  end

  @impl true
  def handle_event("checkout", _, socket) do
    customer = socket.assigns.billing_customer
    encoded_token = encode_token(customer.stripe_id)

    # Get the stripe_id from the current plan that is picked
    plan_stripe_id = Enum.reduce(socket.assigns.plans, nil, fn plan, plan_stripe_id ->
      if is_nil(plan_stripe_id) && plan.id == socket.assigns.chosen_plan_id do
        plan.stripe_id
      else
        plan_stripe_id
      end
    end)

    {:ok, %{id: stripe_session_id, payment_intent: _stripe_id}} =
      Stripe.Session.create(%{
        customer: customer.stripe_id,
        payment_method_types: ["card"],
        line_items: [
          %{
            price: plan_stripe_id,
            quantity: 1
          }
        ],
        mode: "subscription",
        success_url: url(~p"/return_from_stripe?t=success&bp=#{encoded_token}"),
        cancel_url: url(~p"/return_from_stripe?t=cancel&bp=#{encoded_token}")
      })

    {
      :noreply,
      socket
      |> push_event("stripe-session", %{stripe_session_id: stripe_session_id})
    }
  end

  defp list_plans() do
    Billing.list_products_and_plans_for_pricing_page()
  end

  defp format_price(amount) do
    rounded_amount = round(amount / 100)
    "$#{rounded_amount}"
  end

  defp chosen?(plan, chosen_plan_id), do: plan.id == chosen_plan_id
end
