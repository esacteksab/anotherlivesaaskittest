defmodule AnotherTest.Admins.Auth do
  @moduledoc """
  Admin authentication module. Admin authentication is based on
  the Guardian and Bcrypt library.
  """

  alias AnotherTest.Repo
  alias AnotherTest.Admins.Admin

  @doc """
  Tries to authenticate the user via email and password.

  ## Examples
      iex> authenticate_admin("some@email.com", "secret")
      {:ok, %User{}}

      iex> authenticate_admin("some@email.com", "wrong")
      {:error, "Error message"}
  """
  def authenticate_admin(email, password) do
    Repo.get_by(Admin, email: email)
    |> check_password(password)
  end

  defp check_password(admin, password) do
    case Bcrypt.check_pass(admin, password) do
      {:ok, admin} -> {:ok, admin}
      _ -> {:error, "Incorrect email or password"}
    end
  end
end
