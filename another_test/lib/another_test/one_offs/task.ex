defmodule AnotherTest.OneOffs.Task do
  @moduledoc """
  A task can have a unique module name. It will raise
  an error if you try to run the same task again.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "one_off_tasks" do
    field :module, :string

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:module])
    |> validate_required([:module])
  end
end
