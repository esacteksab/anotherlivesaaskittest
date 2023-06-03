defmodule Demo.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:account_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)
      add :role, :string, null: false

      timestamps()
    end

    create index(:account_memberships, [:user_id])
    create index(:account_memberships, [:account_id])
    create unique_index(:account_memberships, [:account_id, :user_id])
  end
end
