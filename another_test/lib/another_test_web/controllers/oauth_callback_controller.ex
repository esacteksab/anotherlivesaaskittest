defmodule AnotherTestWeb.OauthCallbackController do
  use AnotherTestWeb, :controller

  plug Ueberauth

  alias AnotherTest.UserIdentities
  alias AnotherTestWeb.UserAuth
  alias AnotherTest.Users
  alias AnotherTest.Users.User

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserIdentities.find_or_create_user(auth) do
      {:ok, %User{} = user} -> handle_existing_user_login(conn, user)
      {:error, %User{} = user} -> handle_unconnected_oauth_for_user(conn, user)
      {:just_created, %User{} = user} -> handle_new_user_and_login(conn, user)
      {:error, reason} -> handle_error_response(conn, reason)
      _ -> handle_error_response(conn, nil)
    end
  end

  defp handle_existing_user_login(conn, user) do
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> UserAuth.log_in_user(user)
  end

  # This happens when a user is registered but the user is not connected.
  # Since we cant be sure its the same user, we cant sign in.
  defp handle_unconnected_oauth_for_user(conn, _user) do
    conn
    |> put_flash(:error, "User exists but is not connected with this auth method")
    |> redirect(to: ~p"/")
  end

  defp handle_new_user_and_login(conn, user) do
    Users.deliver_user_confirmation_instructions(
      user,
      &url(~p"/users/confirm/#{&1}")
    )

    conn
    |> put_flash(:info, "Account created successfully.")
    |> UserAuth.log_in_user(user)
  end

  defp handle_error_response(conn, "" <> reason) do
    conn
    |> put_flash(:error, reason)
    |> redirect(to: ~p"/")
  end

  defp handle_error_response(conn, _reason) do
    conn
    |> put_flash(:error, "There was an error signing in with this method")
    |> redirect(to: ~p"/")
  end
end
