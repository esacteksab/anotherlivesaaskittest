defmodule AnotherTest.Onboarder.OnboardingTest do
  use AnotherTest.DataCase, async: true

  import AnotherTest.AccountsFixtures

  alias AnotherTest.Onboarding
  alias AnotherTest.Onboarding.Step

  describe "require_onboarding?" do
    test "require_onboarding?/0 returns all onboarders" do
      assert Onboarding.require_onboarding?() == false
    end

    test "require_onboarding?/1 with override true" do
      assert Onboarding.require_onboarding?(true) == true
    end
  end

  describe "get_step_for_account" do
    test "get_step_for_account/1 returns nil when onboarding is not required" do
      account = account_fixture(%{onboarding_required: false})
      assert Onboarding.get_step_for_account(account) == nil
    end

    test "get_step_for_account/1 returns nil when onboarding is completed" do
      account = account_fixture(%{onboarding_completed_at: NaiveDateTime.utc_now()})
      assert Onboarding.get_step_for_account(account) == nil
    end

    test "get_step_for_account/1 returns first step when onboarding_step is nil" do
      account = account_fixture(%{onboarding_required: true, onboarding_step: nil})
      assert %Step{key: "step-1"} = Onboarding.get_step_for_account(account)
    end

    test "get_step_for_account/1 returns second step when onboarding_step is first" do
      account = account_fixture(%{onboarding_required: true, onboarding_step: "step-1"})
      assert %Step{key: "step-2"} = Onboarding.get_step_for_account(account)
    end
  end

  describe "step_is_current_or_previous?" do
    test "step_is_current_or_previous?/2 returns true or false depending of step is completed" do
      step_to_test = Enum.at(Onboarding.steps(), 1)

      result =
        Enum.map(Onboarding.steps(), fn step ->
          Onboarding.step_is_current_or_previous?(step, step_to_test)
        end)

      assert result == [true, true, false]
    end
  end
end
