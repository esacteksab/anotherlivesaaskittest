defmodule AnotherTest.Repo.Migrations.CreateMembershipsAndReceipts do
  use Ecto.Migration

  def change do
    create table(:campaign_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :campaign, :string
      add :step, :string
      add :last_sent_at, :naive_datetime
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps()
    end

    create index(:campaign_memberships, [:user_id])

    create table(:campaign_receipts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :campaign, :string
      add :step, :string
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps(updated_at: false)
    end

    create index(:campaign_receipts, [:user_id, :campaign, :step])
  end
end
