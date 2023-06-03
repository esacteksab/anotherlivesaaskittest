defmodule AnotherTestWeb.MemberLive.Index do
  @moduledoc """
  This memberships page. It is scoped under a specific account id.
  """
  use AnotherTestWeb, :live_view

  alias AnotherTest.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :display_invitation_form?, false)}
  end

  @impl true
  def handle_params(%{"account_id" => account_id}, _url, socket) do
    account = load_account(account_id)

    memberships = load_memberships(account, socket.assigns.current_user)

    current_membership =
      memberships
      |> Enum.find(&(&1.user_id == socket.assigns.current_user.id))

    invitations = load_invitations(account)

    # Make sure that the current_user can access this account
    case Accounts.can_be_accessed_by_a_user?(account, socket.assigns.current_user) do
      true ->
        {:noreply,
         assign(socket,
           account: account,
           memberships: memberships,
           current_membership: current_membership,
           invitations: invitations
         )}

      false ->
        {:noreply, redirect(socket, to: ~p"/accounts")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    membership = Accounts.get_membership!(socket.assigns.account, id)
    {:ok, _} = Accounts.delete_membership(membership)

    memberships = Enum.reject(socket.assigns.memberships, &(&1.id == membership.id))

    {:noreply, assign(socket, :memberships, memberships)}
  end

  def handle_event("delete-invitation", %{"id" => id}, socket) do
    invitation = Accounts.get_invitation!(socket.assigns.account, id)
    {:ok, _} = Accounts.delete_invitation(invitation)

    invitations = Enum.reject(socket.assigns.invitations, &(&1.id == invitation.id))

    {:noreply, assign(socket, :invitations, invitations)}
  end

  @impl true
  def handle_event("display-invitation-form", _, socket) do
    {:noreply, assign(socket, :display_invitation_form?, true)}
  end

  defp load_account(account_id) do
    Accounts.get_account!(account_id)
    |> Accounts.with_members()
  end

  defp load_memberships(%{memberships: [_ | _] = memberships}, current_user) do
    memberships
    |> Enum.sort_by(& &1.member.email)
    |> Enum.sort_by(&(&1.role == :owner), :desc)
    |> Enum.sort_by(&(&1.user_id == current_user.id), :desc)
  end

  defp load_memberships(_, _current_user), do: []

  defp load_invitations(account), do: Accounts.list_invitations(account)

  defp is_owner?(%{role: :owner}), do: true
  defp is_owner?(_), do: false

  defp is_current_member?(%{id: id}, %{id: other_id}), do: id == other_id
  defp is_current_member?(_, _), do: false

  defp has_other_owners?(memberships) do
    memberships
    |> Enum.count(&is_owner?/1) > 1
  end
end
