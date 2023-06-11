defmodule AnotherTestWeb.MemberLive.InvitationFormComponent do
  @moduledoc """
  This component is used for creating a account membership
  invitation.
  """
  use AnotherTestWeb, :live_component

  alias AnotherTest.Accounts
  alias AnotherTest.Accounts.Invitation

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="invitation-form" phx-target={@myself} phx-submit="save">
        <div class="flex items-top">
          <.input
            field={@form[:email]}
            type="text"
            phx-hook="Focus"
            placeholder="Invite a user by email"
          />

          <.button phx-disable-with="Saving..." class="ml-2">Invite</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Accounts.change_invitation(%Invitation{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"invitation" => invitation_params}, socket) do
    case Accounts.create_invitation(
           socket.assigns.account,
           socket.assigns.current_user,
           invitation_params
         ) do
      {:ok, invitation} ->
        notify_parent({:saved, invitation})

        {:noreply,
         socket
         |> put_flash(:info, "Member invited successfully")
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
