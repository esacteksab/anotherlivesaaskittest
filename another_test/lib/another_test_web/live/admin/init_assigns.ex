defmodule AnotherTestWeb.Admin.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  use AnotherTestWeb, :verified_routes

  import Phoenix.Component

  def on_mount(:admin_layout, _params, _session, socket) do
    {:cont, assign(socket, admin_layout: true)}
  end
end
