defmodule AnotherTestWeb.Admin.DashboardLive.Index do
  @moduledoc """
  The view is the placeholder for the admin dashboard
  """
  use AnotherTestWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    :timer.send_interval(1000, self(), :update_chart)

    {:ok, socket}
  end

  @impl true
  def handle_info(:update_chart, socket) do
    value = Enum.random(40..80)

    {
      :noreply,
      socket
      |> push_event("new-point", %{label: "Label", value: value})
    }
  end
end
