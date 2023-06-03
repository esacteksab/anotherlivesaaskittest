defmodule Demo.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :accepted_at, :utc_datetime
      add :declined_at, :utc_datetime
      add :invited_by_user_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:invitations, [:invited_by_user_id])
    create index(:invitations, [:account_id])
    create unique_index(:invitations, [:account_id, :email, :declined_at])
  end
end
