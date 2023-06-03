defmodule AnotherTest.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:admins) do
      add :name, :string
      add :email, :citext, null: false
      add :password_hash, :string, null: false
      add :confirmed_at, :naive_datetime

      timestamps()
    end

    create unique_index(:admins, [:email])
  end
end
