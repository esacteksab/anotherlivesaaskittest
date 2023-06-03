defmodule AnotherTest.AdminsTest do
  use AnotherTest.DataCase, async: true

  import AnotherTest.AdminsFixtures

  alias AnotherTest.Admins
  alias AnotherTest.Admins.Admin

  describe "admins" do
    @update_attrs %{email: "some updated email", name: "some updated name"}
    @invalid_attrs %{email: nil, name: nil}

    test "list_admins/0 returns all admins" do
      admin = admin_fixture()
      assert Admins.list_admins() == [admin]
    end

    test "create_admin/1 requires email and password to be set" do
      {:error, changeset} = Admins.create_admin(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "create_admin/1 validates email and password when given" do
      {:error, changeset} = Admins.create_admin(%{email: "not valid", password: "invalid", password_confirmation: "invalid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["at least one digit or punctuation character", "should be at least 8 character(s)"]
             } = errors_on(changeset)
    end

    test "create_admin/1 validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Admins.create_admin(%{email: too_long, password: too_long, password_confirmation: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "create_admin/1 validates email uniqueness" do
      %{email: email} = admin_fixture()
      {:error, changeset} = Admins.create_admin(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Admins.create_admin(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "create_admin/1 registers admins with a hashed password" do
      email = unique_admin_email()
      {:ok, admin} = Admins.create_admin(%{email: email, password: valid_admin_password(), password_confirmation: valid_admin_password()})
      assert admin.email == email
      assert is_binary(admin.password_hash)
      assert is_nil(admin.password)
    end

    test "update_admin/2 with valid data updates the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{} = admin} = Admins.update_admin(admin, @update_attrs)
      assert admin.email == "some updated email"
      assert admin.name == "some updated name"
    end

    test "update_admin/2 with valid password data updates the admin password" do
      admin = admin_fixture()
      password = "supersecret123"
      update_attrs = %{email: "joe@example.com", password: password, password_confirmation: password}
      assert {:ok, %Admin{} = admin} = Admins.update_admin(admin, update_attrs)
      assert admin.email == "joe@example.com"
      assert {:ok, %Admin{}} = Admins.Auth.authenticate_admin(admin.email, password)
    end

    test "update_admin/2 with invalid data returns error changeset" do
      admin = admin_fixture()
      assert {:error, %Ecto.Changeset{}} = Admins.update_admin(admin, @invalid_attrs)
      assert admin == Admins.get_admin!(admin.id)
    end

    test "delete_admin/1 deletes the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{}} = Admins.delete_admin(admin)
      assert_raise Ecto.NoResultsError, fn -> Admins.get_admin!(admin.id) end
    end

    test "change_admin/1 returns a admin changeset" do
      admin = admin_fixture()
      assert %Ecto.Changeset{} = Admins.change_admin(admin)
    end
  end

  describe "get_admin_by_email/1" do
    test "does not return the admin if the email does not exist" do
      refute Admins.get_admin_by_email("unknown@example.com")
    end

    test "returns the admin if the email exists" do
      %{id: id} = admin = admin_fixture()
      assert %Admin{id: ^id} = Admins.get_admin_by_email(admin.email)
    end
  end

  describe "get_admin!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Admins.get_admin!("7d7cfd8a-7799-4f3e-bad7-4db3af3234f4")
      end
    end

    test "returns the admin with the given id" do
      %{id: id} = admin = admin_fixture()
      assert %Admin{id: ^id} = Admins.get_admin!(admin.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Admin{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
