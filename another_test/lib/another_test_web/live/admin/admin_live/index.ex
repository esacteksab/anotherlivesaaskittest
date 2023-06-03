defmodule AnotherTestWeb.Admin.AdminLive.Index do
  @moduledoc """
  The admin admins index page.
  """
  use AnotherTestWeb, :live_view

  alias AnotherTest.Admins
  alias AnotherTest.Admins.Admin

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
      |> assign_admins()
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Admins.get_admin!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Admin")
    |> assign(:admin, %Admin{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Admins")
    |> assign(:admin, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin = Admins.get_admin!(id)
    {:ok, _} = Admins.delete_admin(admin)

    {:noreply, assign_admins(socket)}
  end

  defp assign_admins(socket) do
    case Admins.paginate_admins(socket.assigns.params) do
      {:ok, {admins, meta}} ->
        assign(socket, %{admins: admins, meta: meta})
      _ ->
        push_navigate(socket, to: ~p"/admin/admins")
    end
  end
end
