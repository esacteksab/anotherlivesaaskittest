defmodule AnotherTest.Users.Data do
  @moduledoc """
  The User data schema.
  Add arbitrary user attributes here
  """
  use AnotherTest.Schema
  import Ecto.Changeset

  embedded_schema do
    field :traffic_source, :string
  end

  def changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [:traffic_source])
  end
end
