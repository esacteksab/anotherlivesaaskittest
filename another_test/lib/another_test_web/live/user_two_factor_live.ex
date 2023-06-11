defmodule AnotherTestWeb.UserTwoFactorLive do
  use AnotherTestWeb, :live_view

  alias AnotherTest.Users

  def render(assigns) do
    ~H"""
    <div class="space-y-2">
      <.header class="text-center">Two Factor Authentication</.header>
      <p class="text-sm text-center">Required for additional security</p>

      <%= if @has_setup do %>
        <p class="text-sm text-center">
          Open your authenticator and add the verification challange code below.
        </p>
      <% else %>
        <%= raw(render_png(@url)) %>
        <p class="text-sm text-center">
          Scan the QR code with your Google authenticator and add the verification challange code below.
        </p>
      <% end %>

      <!-- <.simple_form for={%{}} as={:user} id="verify-2fa-auth" value={:verification}>
        <.input field={{:verification}} name="verification" type="input" required />
        <:actions>
          <button class="w-full" phx-disable-with="Sending..." phx-click="verify">Verify</.button>
        </:actions>
      </.simple_form> -->

      <.simple_form for={@form} id="verify-2fa-auth" phx-update="ignore">
      <.input field={@form[:verification]} type="input" required />
      <:actions>
            <.button phx-disable-with="Verifying..." class="w-full">Verify</.button>
      </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    verification = live_flash(socket.assigns.flash, :verification)
    form = to_form(%{"verification" => verification}, as: "user")

    if user.data && user.data.has_two_factor_auth_setup do
      {:ok, assign(socket, :has_setup, true )}
    else
      {
        :ok,
        socket
        |> assign(:has_setup, false)
        |> assign(:form, form)
        |> assign(:url, Users.generate_authenticator_url(user))
      }
    end
  end

  defp render_png(url) do
    url
    |> EQRCode.encode()
    |> EQRCode.svg()
    |> String.replace("style=\"background-color: #FFF\"", "class=\"w-56 h-56 mx-auto shadow \"")
  end

  def handle_event("verify", %{"user" => %{"verification" => challenge}}, socket) do
    user = socket.assigns.current_user

    if Users.verify_timebased_challenge(user, challenge) do
      Users.update_user(user, %{data: %{has_two_factor_auth_setup: true}})
      token = Phoenix.Token.sign(AnotherTestWeb.Endpoint, "2fa_confirmed", "true")

      {
        :noreply,
        socket
        |> put_flash(:info, "The two factor authentication is setup!")
        |> redirect(to: ~p"/users/two_factor/#{token}")
      }
    else
      {
        :noreply,
        socket
        |> put_flash(:error, "The verification code was not valid. Try again")
        |> push_navigate(to: ~p"/users/two_factor")
      }
    end
  end
end
