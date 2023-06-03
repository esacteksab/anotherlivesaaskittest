defmodule AnotherTestWeb.Schema.GetUserTest do
  use AnotherTestWeb.ConnCase, async: true
  import AnotherTest.GraphqlTestHelpers

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    query($id: ID!) {
      user(id: $id) {
        id
      }
    }
  """

  defp get_post_args(args) do
    %{
      query: @query,
      variables: %{
        "id" => "#{args[:id]}"
      }
    }
  end

  describe "when not logged in" do
    setup [:user_with_invalid_jwt]

    test "get users with invalid credentials", %{conn: conn, user: user} do
      args = get_post_args(%{id: user.id})

      response =
        conn
        |> get_response(args)

      assert %{
               "data" => %{"user" => nil},
               "errors" => [
                 %{
                   "locations" => [_],
                   "message" => "Not Authorized",
                   "path" => ["user"]
                 }
               ]
             } = json_response(response, 200)
    end
  end

  describe "when logged in" do
    setup [:user_with_valid_jwt]

    test "get users with valid credentials", %{conn: conn, jwt: jwt, user: user} do
      id = user.id
      args = get_post_args(%{id: id})

      response =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> get_response(args)

      assert %{
               "data" => %{
                 "user" => %{"id" => ^id}
               }
             } = json_response(response, 200)
    end

    test "get users with invalid id", %{conn: conn, jwt: jwt, user: _user} do
      args = get_post_args(%{id: "9c69897e-3c46-4405-aae8-59e73e53e180"})

      response =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> get_response(args)

      assert %{
               "data" => %{"user" => nil},
               "errors" => [
                 %{
                   "locations" => [_],
                   "message" => "resource_not_found",
                   "path" => ["user"]
                 }
               ]
             } = json_response(response, 200)
    end
  end
end
