defmodule AnotherTestWeb.Admin.AccountLive.Index do
  @moduledoc """
  The admin accounts index page
  """
  use AnotherTestWeb, :live_view

  alias AnotherTest.Accounts
  alias AnotherTest.Accounts.Account

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
      |> assign_accounts(params)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Account")
    |> assign(:account, Accounts.get_account!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Account")
    |> assign(:account, %Account{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Accounts")
    |> assign(:account, nil)
  end

  defp apply_action(socket, :billing_customer, %{"id" => id}) do
    socket
    |> assign(:page_title, "Add Billing Customer")
    |> assign(:account, Accounts.get_account!(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Accounts.get_account!(id)
    {:ok, _} = Accounts.delete_account(account)

    {:noreply, assign_accounts(socket, %{})}
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/accounts?#{params}")}
  end

  defp assign_accounts(socket, params) do
    case Accounts.paginate_accounts(params) do
      {:ok, {accounts, meta}} ->
        assign(socket, %{accounts: accounts, meta: meta})
      _ ->
        push_navigate(socket, to: ~p"/admin/accounts")
    end
  end
end
