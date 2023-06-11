defmodule CoreSpunk.Features.ForgotPasswordTest do
  use ExUnit.Case
  use CoreSpunkWeb, :verified_routes
  use Wallaby.Feature

  import Wallaby.Query
  import CoreSpunk.UsersFixtures

  @email_field text_field("Email")

  feature "a user can recover a password", %{session: session} do
    user = user_fixture()

    session =
      session
      |> visit(~p"/users/reset_password")
      |> assert_text("Forgot your password?")
      |> fill_in(@email_field, with: user.email)
      |> click(button("Send password reset instructions"))
      |> assert_has(
        css(".alert-info p", text: "you will receive instructions to reset your password ")
      )

    assert current_url(session) =~ ~p"/"
  end
end
