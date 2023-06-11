defmodule AnotherTestWeb.AccountLive.FormComponent do
  @moduledoc """
  This component is used for creating an account and setting the first
  membership.
  """
  use AnotherTestWeb, :live_component

  alias AnotherTest.Accounts
  alias AnotherTest.Accounts.Account

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="account-form" phx-target={@myself} phx-submit="save">
        <div class="flex items-top">
          <.input
            field={@form[:name]}
            type="text"
            phx-hook="Focus"
            placeholder="Add name of the team"
          />
          <.button phx-disable-with="Saving..." class="ml-2">Save</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Accounts.change_account(%Account{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"account" => account_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.create_account(user, account_params) do
      {:ok, account} ->
        Accounts.create_membership(account, user, %{role: :owner})
        notify_parent({:saved, account})

        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
