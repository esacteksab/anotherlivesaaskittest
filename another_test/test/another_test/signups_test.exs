defmodule AnotherTest.SignupsTest do
  use AnotherTest.DataCase

  alias AnotherTest.Signups

  describe "signups" do
    alias AnotherTest.Signups.Signup

    import AnotherTest.SignupsFixtures

    @invalid_attrs %{email: nil, signed_of_at: nil, topic: nil}

    test "list_signups/0 returns all signups" do
      signup = signup_fixture()
      assert Signups.list_signups() == [signup]
    end

    test "get_signup!/1 returns the signup with given id" do
      signup = signup_fixture()
      assert Signups.get_signup!(signup.id) == signup
    end

    test "create_signup/1 with valid data creates a signup" do
      valid_attrs = %{email: "some@email", signed_of_at: ~N[2022-03-14 19:47:00], topic: "some topic"}

      assert {:ok, %Signup{} = signup} = Signups.create_signup(valid_attrs)
      assert signup.email == "some@email"
      assert signup.signed_of_at == ~N[2022-03-14 19:47:00]
      assert signup.topic == "some topic"
    end

    test "create_signup/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Signups.create_signup(@invalid_attrs)
    end

    test "update_signup/2 with valid data updates the signup" do
      signup = signup_fixture()
      update_attrs = %{email: "some@updated_email", signed_of_at: ~N[2022-03-15 19:47:00], topic: "some updated topic"}

      assert {:ok, %Signup{} = signup} = Signups.update_signup(signup, update_attrs)
      assert signup.email == "some@updated_email"
      assert signup.signed_of_at == ~N[2022-03-15 19:47:00]
      assert signup.topic == "some updated topic"
    end

    test "update_signup/2 with invalid data returns error changeset" do
      signup = signup_fixture()
      assert {:error, %Ecto.Changeset{}} = Signups.update_signup(signup, @invalid_attrs)
      assert signup == Signups.get_signup!(signup.id)
    end

    test "delete_signup/1 deletes the signup" do
      signup = signup_fixture()
      assert {:ok, %Signup{}} = Signups.delete_signup(signup)
      assert_raise Ecto.NoResultsError, fn -> Signups.get_signup!(signup.id) end
    end

    test "change_signup/1 returns a signup changeset" do
      signup = signup_fixture()
      assert %Ecto.Changeset{} = Signups.change_signup(signup)
    end
  end
end
