defmodule AnotherTest.Repo.Migrations.CreateUserIdentities do
  use Ecto.Migration

  def change do
    create table(:user_identities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :uid, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:user_identities, [:user_id])
    create unique_index(:user_identities, [:uid, :provider])
  end
end
