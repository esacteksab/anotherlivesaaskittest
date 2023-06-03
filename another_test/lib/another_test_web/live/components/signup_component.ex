defmodule AnotherTestWeb.Live.SignupComponent do
  use AnotherTestWeb, :live_component
  @moduledoc """
  This module can be mounted in any LiveView and act as a signup form.

  ## Examples

      <.live_component module={SignupComponent} id="signup-form" topic="some topic" />

      <.live_component module={SignupComponent} id="signup-form" topic="some topic" label="Signup for news" />

      <.live_component module={SignupComponent} id="signup-form" topic="some topic" return_to="/route" />

  """
  alias AnotherTest.Signups

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.form
        for={@form}
        id="signup-form"
        phx-target={@myself}
        phx-submit="save">

        <%= if @submitted do %>
          <div class="py-2 font-semibold">You are successfully signed up!</div>
        <% else %>
          <div class="flex items-top">
            <.input field={@form[:email]} type="text" phx-hook="Focus" placeholder="Signup with email" />
            <.button phx-disable-with="Saving..." class="ml-2">Invite</.button>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Signups.change_signup(%Signups.Signup{})

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_form(changeset)
      |> assign(:submitted, false)
    }
  end

  @impl true
  def handle_event("save", %{"signup" => signup_params}, socket) do
    signup_params = Map.merge(signup_params, %{"topic" => socket.assigns.topic})

    case Signups.create_signup(signup_params) do
      {:ok, signup} ->
        notify_parent({:saved, signup})

        {:noreply,
          socket
          |> handle_success()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp handle_success(socket) do
    if socket.assigns[:return_to] do
      socket
      |> put_flash(:info, "Signup created successfully")
      |> push_redirect(to: socket.assigns.return_to)
    else
      socket
      |> assign(:submitted, true)
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
