defmodule CoreSpunk.Features.SignupTest do
  use ExUnit.Case
  use CoreSpunkWeb, :verified_routes
  use Wallaby.Feature

  import Wallaby.Query
  alias CoreSpunk.Users
  alias CoreSpunk.Users.User

  @sign_up_link css("header a[href='/users/register']")
  @email_field text_field("Email")
  @password_field css("#registration_form_password")

  feature "users can create an account", %{session: session} do
    session =
      session
      |> visit(~p"/")
      |> assert_text("Batteries included")
      |> click(@sign_up_link)
      |> fill_in(@email_field, with: "jbond@example.com")
      |> fill_in(@password_field, with: "supersecret123")
      |> click(button("Create"))
      |> assert_has(css(".alert-info p", text: "Account created successfully!"))

    assert current_url(session) =~ ~p"/"
    assert %User{} = Users.get_user_by_email_and_password("jbond@example.com", "supersecret123")
  end
end
