defmodule AnotherTestWeb.OnboardingLive.Init do
  @moduledoc """
  On Mount hooks and helpers for the onbaording feature.
  """

  import Phoenix.LiveView
  alias AnotherTest.Onboarding

  def on_mount(:maybe_onboard, _params, session, %{assigns: %{current_account: %{} = account}} = socket) do
    override_for_test = Map.get(session, "override_for_test") == true

    with true <- Onboarding.require_onboarding?(override_for_test),
         %{key: step} <- Onboarding.get_step_for_account(account) do

      {:halt, redirect(socket, to: "/onboarding/#{step}")}
    else
      _ ->
        {:cont, socket}
    end
  end

  def on_mount(:maybe_onboard, _params, _session, socket) do
    {:cont, socket}
  end

  def on_mount(:should_be_in_onboarding?, _params, session, socket) do
    override_for_test = Map.get(session, "override_for_test") == true

    if Onboarding.require_onboarding?(override_for_test) && get_next_step(socket.assigns.current_account) do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/")}
    end
  end

  def get_next_step(account) do
    Onboarding.get_step_for_account(account)
  end
end
