defmodule AnotherTest.CampaignsTest do
  use AnotherTest.DataCase

  import AnotherTest.UsersFixtures
  import AnotherTest.CampaignsFixtures

  alias AnotherTest.Campaigns
  alias AnotherTest.Campaigns.Membership
  alias AnotherTest.Campaigns.Receipt
  alias AnotherTest.Campaigns.ExecuteStepWorker

  def setup_user(_) do
    user = user_fixture()
    {:ok, user: user}
  end

  defp clear_queue, do: AnotherTest.Repo.delete_all(Oban.Job)

  defmodule TestCampaign do
    def name, do: :test_campaign
    def steps, do: [:first, :second]
    def first_step, do: :first
    def days_until_next_step(_), do: 7

    def execute_step(step, user) do
      [step, user]
    end

    def apply_scopes(query) do
      sql = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
      send(self(), {:scopes_applied, sql})
      query
    end
  end

  @campaign :campaign_only_used_in_test
  @test_campaign_module [campaign_module: TestCampaign]
  @one_day_ago -3600 * 24

  describe "add_users_to_campaign" do
    setup [:setup_user]

    test "adds a valid user to membership", %{user: user} do
      Campaigns.add_users_to_campaign(@campaign, @test_campaign_module)
      assert [membership] = Campaigns.list_memberships(user)
      assert membership.campaign == :campaign_only_used_in_test
      assert membership.user_id == user.id
      assert membership.step == :first

      # it doesnt create another membership
      Campaigns.add_users_to_campaign(@campaign, @test_campaign_module)
      assert [^membership] = Campaigns.list_memberships(user)
    end

    test "applies the scopes from the campaign module", %{user: _user} do
      Campaigns.add_users_to_campaign(@campaign, @test_campaign_module)
      assert_received {:scopes_applied, _sql}
    end
  end

  describe "run_steps_for_campaign" do
    setup [:setup_user]

    test "executes the step for campaign", %{user: user} do
      # when user is not in campaign
      Campaigns.run_steps_for_campaign(@campaign, @test_campaign_module)
      assert [] = all_enqueued(worker: ExecuteStepWorker)

      # add user to the campaign
      Campaigns.add_users_to_campaign(@campaign, @test_campaign_module)
      Campaigns.run_steps_for_campaign(@campaign, @test_campaign_module)

      args = %{"id" => user.id, "campaign" => "#{@campaign}", "step" => "first"}
      assert [%{args: ^args}] = all_enqueued(worker: ExecuteStepWorker)

      # Manually perform job and clear queue
      perform_job(ExecuteStepWorker, args)
      clear_queue()

      assert Campaigns.has_receipt?(user, @campaign, :first) == true
      assert [data] = Campaigns.get_last_steps(user, @campaign)

      # run campaign again
      Campaigns.run_steps_for_campaign(@campaign, @test_campaign_module)
      assert [] = all_enqueued(worker: ExecuteStepWorker)
      assert [^data] = Campaigns.get_last_steps(user, @campaign)
    end

    test "does not execute the step for campaign when it has only gone 5 days", %{user: user} do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      five_days_ago = NaiveDateTime.add(now, @one_day_ago * 5)

      Campaigns.add_users_to_campaign(@campaign, @test_campaign_module)

      receipt_fixture(user, %{
        inserted_at: five_days_ago,
        campaign: :campaign_only_used_in_test,
        step: :first
      })

      # run campaign steps and check if user was scheduled
      Campaigns.run_steps_for_campaign(@campaign, @test_campaign_module)
      assert [] = all_enqueued(worker: ExecuteStepWorker)
    end

    test "executes the step for campaign when it has gone more than 7 days", %{user: user} do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      eight_days_ago = NaiveDateTime.add(now, @one_day_ago * 8)

      Campaigns.add_users_to_campaign(@campaign, @test_campaign_module)

      receipt_fixture(user, %{
        inserted_at: eight_days_ago,
        campaign: :campaign_only_used_in_test,
        step: :first
      })

      # run campaign steps and check if user was scheduled
      Campaigns.run_steps_for_campaign(@campaign, @test_campaign_module)
      assert [%{args: %{"step" => "second"}}] = all_enqueued(worker: ExecuteStepWorker)
    end

    test "does not execute the step for campaign when it has gone more than 7 days but user has receipt for step",
         %{user: user} do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      nine_days_ago = NaiveDateTime.add(now, @one_day_ago * 9)
      eight_days_ago = NaiveDateTime.add(now, @one_day_ago * 8)

      Campaigns.add_users_to_campaign(@campaign, @test_campaign_module)

      receipt_fixture(user, %{
        inserted_at: nine_days_ago,
        campaign: :campaign_only_used_in_test,
        step: :first
      })

      receipt_fixture(user, %{
        inserted_at: eight_days_ago,
        campaign: :campaign_only_used_in_test,
        step: :second
      })

      # run campaign steps and check if user was scheduled
      Campaigns.run_steps_for_campaign(@campaign, @test_campaign_module)
      assert [] = all_enqueued(worker: ExecuteStepWorker)
    end
  end

  describe "campaign_memberships" do
    setup [:setup_user]

    @invalid_attrs %{campaign: nil, step: nil}

    test "list_campaign_memberships/0 returns all campaign_memberships", %{user: user} do
      membership = membership_fixture(user)
      assert Campaigns.list_memberships(user) == [membership]
    end

    test "get_membership!/1 returns the membership with given id", %{user: user} do
      membership = membership_fixture(user)
      assert Campaigns.get_membership!(user, membership.id) == membership
    end

    test "create_membership/1 with valid data creates a membership", %{user: user} do
      valid_attrs = %{campaign: :onboarding, last_sent_at: ~N[2022-11-13 06:49:00], step: :one}

      assert {:ok, %Membership{} = membership} = Campaigns.create_membership(user, valid_attrs)
      assert membership.campaign == :onboarding
      assert membership.last_sent_at == ~N[2022-11-13 06:49:00]
      assert membership.step == :one
    end

    test "create_membership/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Campaigns.create_membership(user, @invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership", %{user: user} do
      membership = membership_fixture(user)
      update_attrs = %{campaign: :onboarding, last_sent_at: ~N[2022-11-14 06:49:00], step: :two}

      assert {:ok, %Membership{} = membership} =
               Campaigns.update_membership(membership, update_attrs)

      assert membership.campaign == :onboarding
      assert membership.last_sent_at == ~N[2022-11-14 06:49:00]
      assert membership.step == :two
    end

    test "update_membership/2 with invalid data returns error changeset", %{user: user} do
      membership = membership_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Campaigns.update_membership(membership, @invalid_attrs)
      assert membership == Campaigns.get_membership!(user, membership.id)
    end

    test "delete_membership/1 deletes the membership", %{user: user} do
      membership = membership_fixture()
      assert {:ok, %Membership{}} = Campaigns.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Campaigns.get_membership!(user, membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Campaigns.change_membership(membership)
    end
  end

  describe "receipts" do
    setup [:setup_user]

    test "has_receipt?/3 checks if a user has current step", %{user: user} do
      receipt_fixture(user, %{campaign: :some_campaign, step: :some_step})

      assert Campaigns.has_receipt?(user, :wrong, :wrong) == false
      assert Campaigns.has_receipt?(user, :some_campaign, :wrong) == false
      assert Campaigns.has_receipt?(user, :wrong, :some_step) == false
      assert Campaigns.has_receipt?(user, :some_campaign, :some_step) == true
    end

    test "get_last_steps/2 get last steps for a user and campaign", %{user: user} do
      receipt_fixture(user, %{campaign: :some_campaign, step: :two})
      receipt_fixture(user, %{campaign: :other_campaign, step: :one})

      assert Campaigns.get_last_steps(user, :wrong) == []

      assert [
               %{inserted_at: _, step: :two}
             ] = Campaigns.get_last_steps(user, :some_campaign)
    end

    test "create_receipt/1 with valid data creates a receipt", %{user: user} do
      valid_attrs = %{campaign: :some_campaign, step: :some_step}

      assert {:ok, %Receipt{} = receipt} = Campaigns.create_receipt(user, valid_attrs)
      assert receipt.campaign == :some_campaign
      assert receipt.step == :some_step
    end

    @invalid_attrs %{campaign: nil, step: nil}

    test "create_receipt/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Campaigns.create_receipt(user, @invalid_attrs)
    end
  end
end
