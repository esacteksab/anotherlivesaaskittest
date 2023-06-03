defmodule AnotherTest.Campaigns.ExecuteStepWorker do
  @moduledoc """
  The worker is called when a campaign step is executed for
  a user.

  %{id: user.id, campaign: campaign, step: step}
  |> Oban.Job.new(queue: :default, worker: AnotherTest.Campaigns.ExecuteStepWorker)
  |> Oban.insert()
  """
  use Oban.Worker

  alias AnotherTest.Campaigns
  alias AnotherTest.Users

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id, "campaign" => campaign, "step" => step}}) do
    user = Users.get_user!(id)
    campaign_module = Campaigns.get_campaign_module(campaign)
    step = String.to_existing_atom(step)

    campaign_module.execute_step(step, user)
    Campaigns.create_receipt(user, %{campaign: campaign, step: step})

    :ok
  end
end
