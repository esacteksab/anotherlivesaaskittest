defmodule AnotherTestWeb.Admin.SubscriptionLiveTest do
  use AnotherTestWeb.ConnCase

  import Phoenix.LiveViewTest
  import AnotherTest.BillingFixtures

  defp create_subscription(_) do
    subscription = subscription_fixture()
    %{subscription: subscription}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_subscription]

    test "lists all subscriptions", %{conn: conn, subscription: subscription} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/subscriptions")

      assert html =~ "subscriptions"
      assert html =~ subscription.status
    end
  end

  describe "Show" do
    setup [:create_subscription]

    test "displays subscription", %{conn: conn, subscription: subscription} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/subscriptions/#{subscription}")

      assert html =~ "Show Subscription"
      assert html =~ subscription.status
    end
  end
end
