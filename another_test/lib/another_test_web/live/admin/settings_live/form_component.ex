defmodule AnotherTestWeb.Admin.SettingLive.FormComponent do
  @moduledoc """
  The admin settings form component
  """
  use AnotherTestWeb, :live_component

  alias AnotherTest.Admins

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id={@id}
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:email]} type="text" label="Email" />

        <.input field={@form[:password]} type="password" label="Password" />
        <small class="block my-1 text-info">Leave blank if you don't want to change</small>

        <.input field={@form[:password_confirmation]} type="password" label="Password Confirmation" />

        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{admin: admin} = assigns, socket) do
    changeset = Admins.change_admin(admin)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"admin" => admin_params}, socket) do
    changeset =
      socket.assigns.admin
      |> Admins.change_admin(admin_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"admin" => admin_params}, socket) do
    case Admins.update_admin(socket.assigns.admin, admin_params) do
      {:ok, admin} ->
        notify_parent({:saved, admin})

        {
          :noreply,
          socket
          |> put_flash(:info, "User updated successfully")
          |> push_redirect(to: socket.assigns.navigate)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
