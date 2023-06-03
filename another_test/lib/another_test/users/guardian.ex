defmodule AnotherTest.Users.Guardian do
  @moduledoc """
  Module is responsible for encoding and decoding JWT for users.
  """
  use Guardian, otp_app: :another_test

  alias AnotherTest.Users

  @doc """
  Used when encoding a JWT for the GraphQL authentication.
  """
  def subject_for_token(user, _claims) do
    {:ok, %{user_id: to_string(user.id)}}
  end

  @doc """
  Used when decoding a JWT for the GraphQL authentication.
  """
  def resource_from_claims(%{"sub" => %{"user_id" => user_id}}) do
    user = Users.get_user!(user_id)

    {:ok, %{user: user}}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
