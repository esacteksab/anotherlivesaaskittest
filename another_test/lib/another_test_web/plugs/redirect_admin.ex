defmodule AnotherTestWeb.Plugs.RedirectAdmin do
  @moduledoc """
  This plug ensures a logged in admin cant access the admin login page
  """
  use AnotherTestWeb, :verified_routes

  import Phoenix.Controller, only: [redirect: 2]
  import Plug.Conn, only: [halt: 1]

  alias AnotherTest.Admins.Guardian

  def init(options), do: options

  def call(conn, _opts) do
    if Guardian.Plug.current_resource(conn, key: :admin) do
      conn
      |> redirect(to: ~p"/admin")
      |> halt()
    else
      conn
    end
  end
end
