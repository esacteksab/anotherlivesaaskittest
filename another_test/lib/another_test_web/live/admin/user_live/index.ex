defmodule AnotherTestWeb.Admin.UserLive.Index do
  @moduledoc """
  The admin users index page
  """
  use AnotherTestWeb, :live_view

  alias AnotherTest.Users

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {
      :noreply,
      socket
      |> assign(:params, params)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
    |> assign_users(params)
    |> assign(:params, params)
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/users?#{params}")}
  end

  defp assign_users(socket, params) do
    case Users.paginate_users(params) do
      {:ok, {users, meta}} ->
        assign(socket, %{users: users, meta: meta})

      _ ->
        push_navigate(socket, to: ~p"/admin/users")
    end
  end
end
