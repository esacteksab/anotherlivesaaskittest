defmodule AnotherTestWeb.Admin.SessionControllerTest do
  use AnotherTestWeb.ConnCase, async: true

  import AnotherTest.AdminsFixtures

  describe "new admin session" do
    test "renders form and allows first admin to register", %{conn: conn} do
      conn = get(conn, ~p"/admin/sign_in")
      response = html_response(conn, 200)
      assert response =~ "Login</h5>"
      assert response =~ "There is no admin created!"
      assert response =~ "Create and login"
    end

    test "renders form and display magic link option when an admin exists", %{conn: conn} do
      admin_fixture()

      conn = get(conn, ~p"/admin/sign_in")
      response = html_response(conn, 200)
      assert response =~ "Login</h5>"
      assert response =~ "Login with magic link</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_admin(admin_fixture())
        |> get(~p"/admin/sign_in")

      assert redirected_to(conn) == "/admin"
    end
  end

  describe "create admin session" do
    test "with valid data it logs in the admin", %{conn: conn} do
      admin = admin_fixture()

      conn =
        post(conn, ~p"/admin/sign_in", %{
          admin: %{
            email: admin.email,
            password: valid_admin_password(),
            password_confirmation: valid_admin_password()
          }
        })

      assert redirected_to(conn) == "/admin"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/admin/accounts")
      response = html_response(conn, 200)
      assert response =~ "Sign Out"
    end

    test "render errors for invalid data", %{conn: conn} do
      admin = admin_fixture()

      conn =
        post(conn, ~p"/admin/sign_in", %{
          admin: %{
            email: admin.email,
            password: "wrongpass",
            password_confirmation: "wrongpass"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "Login</h5>"
      assert response =~ "Login with magic link</a>"
    end
  end

  describe "delete admin session" do
    test "deletes a logged in admin", %{conn: conn} do
      conn =
        conn
        |> log_in_admin(admin_fixture())
        |> delete(~p"/admin/sign_out")

      assert redirected_to(conn) == "/admin/sign_in"

      conn = get(conn, "/admin/accounts")
      assert redirected_to(conn) == "/admin/sign_in"
    end
  end
end
