defmodule AnotherTestWeb.Admin.AccountLiveTest do
  use AnotherTestWeb.ConnCase

  import Phoenix.LiveViewTest
  import AnotherTest.AccountsFixtures

  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_account(_) do
    account = account_fixture()
    %{account: account}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_account]

    test "lists all accounts", %{conn: conn, account: account} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/accounts")

      assert html =~ "Accounts"
      assert html =~ account.name
    end
  end

  describe "Show" do
    setup [:create_account]

    test "displays account", %{conn: conn, account: account} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/accounts/#{account}")

      assert html =~ "Show Account"
      assert html =~ account.name
    end

    test "updates account within modal", %{conn: conn, account: account} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/accounts/#{account}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Account"

      assert_patch(show_live, ~p"/admin/accounts/#{account}/show/edit")

      assert show_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#account-form", account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/accounts/#{account}")

      assert html =~ "Account updated successfully"
      assert html =~ "some updated name"
    end
  end
end
