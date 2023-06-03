defmodule AnotherTestWeb.BillingLive.Index do
  @moduledoc """
  The Billing info page. This Module requires that current_user
  and current_account is set before.

  This module assumes current_user has been set.
  """
  use AnotherTestWeb, :live_view

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Invoice
  alias AnotherTest.Billing.Stripe.SynchronizeCustomer
  alias AnotherTest.Billing.Stripe.SynchronizeSubscriptions

  @impl true
  def mount(_params, _session, socket) do
    billing_customer = get_billing_customer(socket.assigns.current_user)
    invoices = get_invoices(billing_customer)
    Process.send(self(), {:sync_customer, billing_customer}, [])

    {
      :ok,
      socket
      |> assign(:billing_customer, billing_customer)
      |> assign(:invoices, invoices)
    }
  end

  @impl true
  def handle_params(%{"sync" => "true"}, _url, socket) do
    SynchronizeSubscriptions.run()

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:sync_customer, billing_customer}, socket) do
    # Get the latest payment info from Stripe and refetch the customer
    SynchronizeCustomer.run(billing_customer)
    billing_customer = get_billing_customer(socket.assigns.current_user)

    {:noreply, assign(socket, :billing_customer, billing_customer)}
  end

  defp get_billing_customer(current_user) do
    Billing.get_billing_customer_for_user(current_user)
  end

  defp get_invoices(billing_customer) do
    Billing.list_records(Invoice, where: [remote_customer_id: billing_customer.id], order_by: [desc: :inserted_at])
  end
end
