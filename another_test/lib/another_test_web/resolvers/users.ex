defmodule AnotherTestWeb.Resolvers.Users do
  @moduledoc """
  User relates GraphQL resolvers
  """
  alias AnotherTest.Users
  alias AnotherTest.Users.User

  def get_user(%{id: id}, %{context: %{current_user: _user}}) do
    {:ok, Users.get_user!(id)}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end

  def get_user(_args, _context), do: {:error, "Not Authorized"}

  def login(%{email: email, password: password}, _info) do
    with %User{} = user <- Users.get_user_by_email_and_password(email, password),
         {:ok, jwt, _full_claims} <- Users.Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt}}
    else
      _ -> {:error, "Incorrect email or password"}
    end
  end
end
