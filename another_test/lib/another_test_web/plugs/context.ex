defmodule AnotherTestWeb.Context do
  @moduledoc """
  This module is used in the GraphQL pipeling and sets
  current_user to the graphql context and mekes is accessible
  in the resolvers.
  """
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      _ ->
        conn
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{user: user}, _claims} <-
           AnotherTest.Users.Guardian.resource_from_token(token) do
      {:ok, %{current_user: user, token: token}}
    end
  end
end
