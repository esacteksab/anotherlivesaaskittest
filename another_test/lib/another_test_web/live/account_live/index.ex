defmodule AnotherTestWeb.AccountLive.Index do
  @moduledoc """
  This accounts page. Where a uses can see the conected accounts
  including the personal account.
  It is also possible to create new accounts from this page.
  """
  use AnotherTestWeb, :live_view

  alias AnotherTest.Users
  alias AnotherTest.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user =
      socket.assigns.current_user
      |> Users.with_memberships()

    {
      :ok,
      socket
      |> assign(:display_form?, false)
      |> assign(:memberships, user.memberships)
      |> assign(:member_counts, get_member_counts(user))
      |> assign(:invitations, get_open_invitations(user))
    }
  end

  @impl true
  def handle_event("display-form", _, socket) do
    {:noreply, assign(socket, :display_form?, true)}
  end

  def handle_event("accept-invitation", %{"id" => id}, socket) do
    invitation = Enum.find(socket.assigns.invitations, &(&1.id == id))
    invitations = Enum.reject(socket.assigns.invitations, &(&1.id == id))

    Accounts.update_invitation(invitation, %{accepted_at: DateTime.utc_now()})
    Accounts.create_membership(invitation.account, socket.assigns.current_user)

    {:noreply, assign(socket, :invitations, invitations)}
  end

  def handle_event("decline-invitation", %{"id" => id}, socket) do
    invitation = Enum.find(socket.assigns.invitations, &(&1.id == id))
    invitations = Enum.reject(socket.assigns.invitations, &(&1.id == id))

    Accounts.update_invitation(invitation, %{declined_at: DateTime.utc_now()})

    {:noreply, assign(socket, :invitations, invitations)}
  end

  defp get_member_counts(%{accounts: [_ | _] = accounts}) do
    accounts
    |> Accounts.with_members()
    |> Enum.reduce(%{}, fn account, acc ->
      Map.put(acc, account.id, length(account.members))
    end)
  end

  defp get_member_counts(_), do: %{}

  defp get_open_invitations(user), do: Accounts.list_invitations_for_user(user)
end
