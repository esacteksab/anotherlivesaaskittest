defmodule AnotherTestWeb.OnboardingLiveTest do
  use AnotherTestWeb.ConnCase

  import Phoenix.LiveViewTest

  def setup_onbarding_account(%{conn: conn, user: user}) do
    account = AnotherTest.Users.with_personal_account(user).personal_account
    AnotherTest.Accounts.update_account(account, %{onboarding_required: true})

    %{conn: conn}
  end

  def enable_onboarding_requirement(%{conn: conn}) do
    %{conn: Plug.Conn.put_session(conn, :override_for_test, true)}
  end

  describe "onboarding" do
    setup [:register_and_log_in_user, :setup_onbarding_account, :enable_onboarding_requirement]

    test "when onboarding is required, it should redirect", %{conn: conn} do
      assert {:error, {:redirect, %{to: path}}} = live(conn, "/requires_onboarding")
      assert path =~ "/onboarding/step-1"
    end

    test "when completing a step, it gets redirected", %{conn: conn} do
      assert {:ok, view, _html} = live(conn, "/onboarding/step-1")
      assert render(view) =~ "Onboarding"

      assert view
             |> element("button", "Complete step")
             |> render_click()

      assert assert {:error, {:live_redirect, %{to: "/onboarding"}}} =
                      view
                      |> element("button", "Continue")
                      |> render_click()
    end
  end
end
