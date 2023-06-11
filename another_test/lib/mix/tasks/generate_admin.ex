defmodule Mix.Tasks.GenerateAdmin do
  @shortdoc "Genrate an admin account and randomize password"

  @moduledoc """
  # run: mix generate_admin email@example.com
  """
  use Mix.Task

  @doc false
  def run([email]) do
    Application.ensure_all_started(:another_test)

    case AnotherTest.Admins.GenerateAdmin.generate_admin(email) do
      {:ok, email, password} ->
        Mix.shell().info("""
        An admin was created with the
          email: #{email}
          password: #{password}
        """)

      {:error, %Ecto.Changeset{} = changeset} ->
        Mix.shell().info("""
        There was en error:
          #{inspect(changeset.errors)}
        """)
    end
  end
end
