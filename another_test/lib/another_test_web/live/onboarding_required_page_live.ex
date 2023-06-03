defmodule AnotherTestWeb.OnboardingRequiredPageLive do
  @moduledoc false
  use AnotherTestWeb, :live_view

  on_mount {AnotherTestWeb.OnboardingLive.Init, :maybe_onboard}

  def render(assigns) do
    ~H"""
    Just some example content that is here to see when you have completed the onboarding.
    """
  end
end
