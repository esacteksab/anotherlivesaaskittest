defmodule AnotherTestWeb.Plugs.RequireCurrentAdmin do
  @moduledoc """
  This plug is mounted for the admin pages and is responsible for making sure
  there is a current admin or redirect the user to the admin login page.
  """
  use AnotherTestWeb, :verified_routes

  import Phoenix.Controller, only: [redirect: 2]
  import Plug.Conn, only: [halt: 1]

  alias AnotherTest.Admins.Admin

  def init(options), do: options

  def call(conn, _opts) do
    case conn.assigns[:current_admin] do
      %Admin{} ->
        conn

      _ ->
        conn
        |> redirect(to: ~p"/admin/sign_in")
        |> halt()
    end
  end
end
