defmodule AnotherTestWeb.MemberLive.RoleFormComponent do
  @moduledoc """
  This component is used for setting role on a membership from a select list
  """
  use AnotherTestWeb, :live_component

  alias AnotherTest.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <span>
      <.form for={@form} id="member-form-#{@membership.id}" phx-target={@myself} phx-change="save">
        <.input field={@form[:role]} type="select" options={[:owner, :member]} />
      </.form>
    </span>
    """
  end

  @impl true
  def update(%{membership: membership} = assigns, socket) do
    changeset = Accounts.change_membership(membership)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"membership" => membership_params}, socket) do
    case Accounts.update_membership(socket.assigns.membership, membership_params) do
      {:ok, member} ->
        notify_parent({:saved, member})

        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
