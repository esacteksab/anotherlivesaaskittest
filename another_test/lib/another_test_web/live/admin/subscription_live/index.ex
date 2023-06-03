defmodule AnotherTestWeb.Admin.SubscriptionLive.Index do
  @moduledoc """
  The admin subscriptions index page.
  """
  use AnotherTestWeb, :live_view

  alias AnotherTest.Billing

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, "Listing Subscriptions")
      |> assign_subscriptions(params)
      |> assign(:params, params)
    }
  end

  defp assign_subscriptions(socket, params) do
    case Billing.paginate_subscriptions(params) do
      {:ok, {subscriptions, meta}} ->
        assign(socket, %{subscriptions: subscriptions, meta: meta})
      _ ->
        push_navigate(socket, to: ~p"/admin/subscriptions")
    end
  end

  defp human_date(datetime), do: human_date(datetime, "%x")
  defp human_date(nil, _), do: nil
  defp human_date(datetime, format), do: Calendar.strftime datetime, format
end
