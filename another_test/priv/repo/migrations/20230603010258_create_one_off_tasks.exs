defmodule AnotherTest.Repo.Migrations.CreateOneOffTasks do
  use Ecto.Migration

  def change do
    create table(:one_off_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :module, :string, null: false

      timestamps(updated_at: false)
    end

    create unique_index(:one_off_tasks, [:module])
  end
end
