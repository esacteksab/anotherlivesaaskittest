defmodule AnotherTestWeb.Plugs.SetCurrentAdminAccount do
  @moduledoc """
  This plug is used when an admin is selecting a specfic
  account in the admin interface.
  """
  import Plug.Conn, only: [assign: 3, get_session: 2]

  alias AnotherTest.Accounts

  def init(options), do: options

  def call(conn, _opts) do
    case get_session(conn, :admin_account_id) do
      nil ->
        conn
      id ->
        account = Accounts.get_account!(id)
        assign(conn, :current_admin_account, account)
    end
  end
end
