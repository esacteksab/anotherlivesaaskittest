defmodule Demo.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :personal, :boolean, default: false, null: false
      add :created_by_user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps()
    end

    create index(:accounts, [:created_by_user_id])
    create unique_index(:accounts, [:created_by_user_id], name: "accounts_limit_personal_index", where: "personal = true")

    alter table(:users) do
      add :current_account_id, :binary
      add :data, :map
    end

    create index(:users, :data, using: "gin")
  end
end
