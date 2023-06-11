defmodule AnotherTestWeb.Plugs.SetCurrentAdmin do
  @moduledoc """
  This plug is used to set current_admin in assigns
  and current_admin_id in the session.
  """
  import Plug.Conn, only: [assign: 3, put_session: 3]

  alias AnotherTest.Admins.Admin

  def init(options), do: options

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      %Admin{} = admin ->
        conn
        |> assign(:current_admin, admin)
        |> put_session(:current_admin_id, admin.id)

      _ ->
        conn
    end
  end
end
