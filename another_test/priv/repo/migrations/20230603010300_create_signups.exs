defmodule AnotherTest.Repo.Migrations.CreateSignups do
  use Ecto.Migration

  def change do
    create table(:signups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :name, :string
      add :phone, :string
      add :topic, :string
      add :signed_of_at, :naive_datetime

      timestamps()
    end

    create unique_index(:signups, [:email, :topic])
  end
end
