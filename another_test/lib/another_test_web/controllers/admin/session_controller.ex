defmodule AnotherTestWeb.Admin.SessionController do
  use AnotherTestWeb, :controller

  import AnotherTest.Admins.GenerateAdmin
  alias AnotherTest.Admins
  alias AnotherTest.Admins.Guardian

  plug AnotherTestWeb.Plugs.RedirectAdmin when action in [:new, :create]

  def new(conn, _) do
    form = Phoenix.HTML.FormData.to_form(%{"email" => nil}, as: "admin")
    render(conn, "new.html", form: form, zero_admins?: zero_admins?())
  end

  def create(conn, %{"admin" => %{"email" => email, "password" => password}}) do
    Admins.Auth.authenticate_admin(email, password)
    |> login_reply(conn)
  end

  def create(conn, %{"admin" => %{"email" => email}}) do
    with true <- zero_admins?(),
         {:ok, email, password} <- generate_admin(email) do
      Admins.Auth.authenticate_admin(email, password)
      |> login_reply(conn, "Your password is: #{password}")
    else
      _ ->
        Admins.Auth.authenticate_admin(email, "Error creating admin")
        |> login_reply(conn)
    end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: ~p"/admin/sign_in")
  end

  defp login_reply({:ok, admin}, conn), do: login_reply({:ok, admin}, conn, "Welcome back!")

  defp login_reply({:error, reason}, conn), do: login_reply({:error, reason}, conn, nil)

  defp login_reply({:ok, admin}, conn, flash) do
    conn
    |> put_flash(:info, flash)
    |> Guardian.Plug.sign_in(admin, %{}, key: :admin)
    |> redirect(to: ~p"/admin")
  end

  defp login_reply({:error, reason}, conn, flash) do
    conn
    |> put_flash(:error, flash || to_string(reason))
    |> new(%{})
  end
end
