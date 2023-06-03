defmodule AnotherTestWeb.Admin.ResetPasswordControllerTest do
  use AnotherTestWeb.ConnCase, async: true

  import AnotherTest.AdminsFixtures

  describe "new admin reset" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/reset_password")
      response = html_response(conn, 200)
      assert response =~ "Forgot password?</h5>"
      assert response =~ "Login with email and password</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_admin(admin_fixture())
        |> get(~p"/admin/reset_password")

      assert redirected_to(conn) == "/admin"
    end
  end

  describe "create magic token" do
    test "with valid data it sends a magic token in an email", %{conn: conn} do
      admin = admin_fixture()

      conn =
        post(conn, ~p"/admin/reset_password", %{
          admin: %{
            email: admin.email
          }
        })

      assert_received {:email, %Swoosh.Email{html_body: html_body}}
      assert html_body =~ "Please use the following link to sign in"
      assert redirected_to(conn) == "/admin/reset_password"
    end

    test "with a non existing email it doesnt send an email", %{conn: conn} do
      conn =
        post(conn, ~p"/admin/reset_password", %{
          admin: %{
            email: "wrong@example.com"
          }
        })

      refute_received {:delivered_email, _}
      assert redirected_to(conn) == "/admin/reset_password"
    end
  end

  describe "login with magic token" do
    test "with a valid token it signs in admin and redirects", %{conn: conn} do
      admin = admin_fixture()
      token = Phoenix.Token.sign(AnotherTestWeb.Endpoint, "admin_auth", admin.id)

      conn = get(conn, ~p"/admin/reset_password/#{token}")
      assert redirected_to(conn) == "/admin"
    end

    test "with an invalid token it redirects admin back to reset_password", %{conn: conn} do
      admin_fixture()
      token = "wrongtoken"

      conn = get(conn, ~p"/admin/reset_password/#{token}")
      assert redirected_to(conn) == "/admin/reset_password"
    end
  end
end
