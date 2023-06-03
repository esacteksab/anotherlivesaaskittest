defmodule AnotherTestWeb.Live.BillingLiveTest do
  use AnotherTestWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "logged in" do
    setup :register_and_log_in_user

    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/billing")
      assert disconnected_html =~ "Invoice History"
      assert render(page_live) =~ "Invoice History"
    end
  end
end
