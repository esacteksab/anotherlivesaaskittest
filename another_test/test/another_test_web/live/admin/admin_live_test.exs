defmodule AnotherTestWeb.Admin.AdminLiveTest do
  use AnotherTestWeb.ConnCase

  import Phoenix.LiveViewTest
  import AnotherTest.AdminsFixtures

  @update_attrs %{email: "some_updated@email.com", name: "some updated name"}
  @invalid_attrs %{email: nil, name: nil}

  defp create_admin(_) do
    admin = admin_fixture()
    %{admin: admin}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_admin]

    test "lists all admins", %{conn: conn, admin: admin} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/admins")

      assert html =~ "admins"
      assert html =~ admin.name
    end

    test "saves new admin", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/admins/new")

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#admin-form", admin: %{email: unique_admin_email(), name: "some name"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/admins")

      assert html =~ "Admin created successfully"
      assert html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_admin]

    test "displays admin", %{conn: conn, admin: admin} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/admins/#{admin}")

      assert html =~ "Show Admin"
      assert html =~ admin.name
    end

    test "updates admin within modal", %{conn: conn, admin: admin} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/admins/#{admin}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(show_live, ~p"/admin/admins/#{admin}/show/edit")

      assert show_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#admin-form", admin: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/admins/#{admin}")

      assert html =~ "Admin updated successfully"
      assert html =~ "some updated name"
    end
  end
end
