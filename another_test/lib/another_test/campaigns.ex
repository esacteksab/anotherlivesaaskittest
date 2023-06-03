defmodule AnotherTest.Campaigns do
  @moduledoc """
  The Campaigns context.
  """

  import Ecto.Query, warn: false
  alias AnotherTest.Repo
  alias AnotherTest.Users.User
  alias AnotherTest.Campaigns.Membership
  alias AnotherTest.Campaigns.Receipt
  alias AnotherTest.Campaigns.ExecuteStepWorker

  def active_campaigns do
    [
      ## Insert campaigns below
      :initial_campaign,
    ]
  end

  # An uns of magic to dynamic find the correct campaign
  def get_campaign_module(:campaign_only_used_in_test), do: AnotherTest.CampaignsTest.TestCampaign
  def get_campaign_module("campaign_only_used_in_test"), do: AnotherTest.CampaignsTest.TestCampaign
  def get_campaign_module(campaign_name) do
    path_list = Macro.underscore(__MODULE__)
    Macro.camelize("elixir/#{path_list}/#{campaign_name}") |> String.to_atom()
  end

  def run_campaigns do
    active_campaigns()
    |> Enum.each(fn campaign ->
      add_users_to_campaign(campaign)
      run_steps_for_campaign(campaign)
      :ok
    end)
  end

  def add_users_to_campaign(campaign, opts \\ []) do
    campaign_module = Keyword.get(opts, :campaign_module) || get_campaign_module(campaign)
    first_step = campaign_module.first_step

    base_users_query()
    |> not_in_campaign_query(campaign)
    |> campaign_module.apply_scopes()
    |> Repo.all()
    |> Enum.map(fn user ->
      create_membership(user, %{campaign: campaign, step: first_step})
      user
    end)
  end

  def run_steps_for_campaign(campaign, opts \\ []) do
    campaign_module = Keyword.get(opts, :campaign_module) || get_campaign_module(campaign)

    included_users_query =
      base_users_query()
      |> in_campaign_query(campaign)
      |> campaign_module.apply_scopes()

    campaign_module.steps
    |> Enum.with_index()
    |> Enum.map(fn
      {step, 0} ->
        # This is the first step. The logic here is to find users that have
        # not received any receipts at all.
        included_users_query
        |> no_receipts_query(campaign)
        |> execute_and_schedule_step_for_users(campaign, step)

      {step, idx} ->
        # In the following steps, identify the previous step and make two checks
        # 1. If the correct amount of days has passed since last campaign step was executed
        # 2. Make sure that the users last step receipt, is the previous step
        previous_step = Enum.at(campaign_module.steps, idx - 1)
        days_between_steps = campaign_module.days_until_next_step(previous_step)

        included_users_query
        |> days_since_last_receipt_grace_period(campaign, days_between_steps)
        |> max_step_is_previous_receipts_query(campaign, previous_step)
        |> execute_and_schedule_step_for_users(campaign, step)
    end)
  end

  defp execute_and_schedule_step_for_users(query, campaign, step) do
    query
    |> Repo.all()
    |> Enum.each(fn %{id: user_id} ->
      %{id: user_id, campaign: campaign, step: step}
      |> Oban.Job.new(queue: :default, worker: ExecuteStepWorker)
      |> Oban.insert()
    end)
  end

  @doc """
  Starts a base user query that can be piped into further conditions.
  """
  def base_users_query do
    from u in User, as: :user # add permission check here as well
  end

  @doc """
  Filters out users that are already in a campaign
  """
  def not_in_campaign_query(query, campaign) do
    in_campaign_subquery = from(
      m in AnotherTest.Campaigns.Membership,
      where: m.user_id == parent_as(:user).id,
      where: m.campaign == ^campaign,
      select: 1
    )
    from u in query,
      where: not exists(in_campaign_subquery)
  end

  @doc """
  Selects users that are in a campaign
  """
  def in_campaign_query(query, campaign) do
    in_campaign_subquery = from(
      m in AnotherTest.Campaigns.Membership,
      where: m.user_id == parent_as(:user).id,
      where: m.campaign == ^campaign,
      select: 1
    )
    from u in query,
      where: exists(in_campaign_subquery)
  end

  @doc """
  Add a subquery condition to find users which has not
  received any receipts for the campaign.
  """
  def no_receipts_query(query, campaign) do
    in_campaign_subquery = from(
      r in Receipt,
      where: r.user_id == parent_as(:user).id,
      where: r.campaign == ^campaign,
      select: 1
    )
    from u in query,
      where: not exists(in_campaign_subquery)
  end

  @doc """
  Add a subquery condition to exclude users that did receive a receipt
  less than x number of days ago.
  """
  def days_since_last_receipt_grace_period(query, campaign, days_between_steps) do
    last_reseipt_for_campaign = from(
      r in Receipt,
      where: r.user_id == parent_as(:user).id,
      where: r.campaign == ^campaign,
      where: r.inserted_at > ago(^days_between_steps, "day")
    )

    from u in query,
      where: not exists(last_reseipt_for_campaign)
  end

  @doc """
  Subquery to make sure the previous step is the last step
  a user have a receipt for.
  """
  def max_step_is_previous_receipts_query(query, campaign, previous_step) do
    max_step_for_campaign = from(
      r in Receipt,
      where: r.user_id == parent_as(:user).id,
      where: r.campaign == ^campaign,
      order_by: [desc: :inserted_at],
      limit: 1,
      select: r.step
    )

    from u in query,
      where: subquery(max_step_for_campaign) == ^"#{previous_step}"
  end

  @doc """
  Returns the list of memberships for a specific user.

  ## Examples

      iex> list_memberships(user)
      [%Membership{}, ...]

  """
  def list_campaigns() do
    Repo.all(from m in Membership, select: m.campaign, distinct: true)
    |> Enum.sort()
    |> Enum.map(fn campaign ->
      campaign_module = get_campaign_module(campaign)
      %{name: campaign, steps: campaign_module.steps, days_between: campaign_module.days_between}
    end)
  end

  @doc """
  Returns a map grouped on camaign and step with the shape:

      %{
        {:initial_campaign, :one} => %{
          count: 3,
          last_executed_at: ~N[2022-11-18 06:26:50]
        }
      }

  """
  def list_grouped_membership_data() do
    from(m in Membership,
      group_by: [m.campaign, m.step],
      select: %{
        campaign: m.campaign,
        step: m.step,
        count: count(m.id),
        last_executed_at: max(m.inserted_at)
      }
    )
    |> Repo.all()
    |> Enum.reduce(%{}, fn row, memo ->
      key = {Map.get(row, :campaign), Map.get(row, :step)}
      data = Map.take(row, [:count, :last_executed_at])
      Map.put(memo, key, data)
    end)
  end

  @doc """
  Returns the list of memberships for a specific user.

  ## Examples

      iex> list_memberships(user)
      [%Membership{}, ...]

  """
  def list_memberships(user) do
    Repo.all(from u in Membership, where: u.user_id == ^user.id)
  end

  @doc """
  Gets a single membership for a specific user.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(user, 123)
      %Membership{}

      iex> get_membership!(user, 456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(user, id), do: Repo.get_by!(Membership, user_id: user.id, id: id)

  @doc """
  Creates a membership for a specific user.

  ## Examples

      iex> create_membership(user, %{field: value})
      {:ok, %Membership{}}

      iex> create_membership(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(user, attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(membership)
      {:ok, %Membership{}}

      iex> delete_membership(membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end


  @doc """
  Checks if a user has a receipt for campaign and step.

  Returns true or false.

  ## Examples

      iex> has_receipt?(user, :onboarding, :one)
      true

      iex> has_receipt?(user, :onboarding, :two)
      false

  """
  def has_receipt?(user, campaign, step) do
    from(
      r in Receipt,
      where: r.user_id == ^user.id,
      where: r.campaign == ^campaign,
      where: r.step == ^step
    )
    |> Repo.exists?()
  end

  def get_last_steps(user, campaign) do
    from(
      r in Receipt,
      where: r.user_id == ^user.id,
      where: r.campaign == ^campaign,
      select: %{inserted_at: r.inserted_at, step: r.step},
      order_by: [desc: :inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Creates a receipt for a specific user.

  ## Examples

      iex> create_receipt(user, %{field: value})
      {:ok, %Receipt{}}

      iex> create_receipt(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_receipt(user, attrs \\ %{}) do
    %Receipt{}
    |> Receipt.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end
end
