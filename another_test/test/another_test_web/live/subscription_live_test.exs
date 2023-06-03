defmodule AnotherTestWeb.Live.SubscriptionLiveTest do
  use AnotherTestWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "logged in" do
    setup :register_and_log_in_user

    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/subscriptions/new")
      assert disconnected_html =~ "Start Subscription"
      assert render(page_live) =~ "Start Subscription"
    end
  end
end
