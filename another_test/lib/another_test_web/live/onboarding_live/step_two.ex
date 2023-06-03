defmodule AnotherTestWeb.OnboardingLive.StepTwo do
  @moduledoc """
  Step two of the onboarding steps. Change this component to fir your needs.
  Make sure the user triggers the handle_event complete.
  """
  use AnotherTestWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:step_completed, false)}
  end

  @impl true
  def handle_event("complete", _, socket) do
    {:noreply, assign(socket, :step_completed, true)}
  end
end
