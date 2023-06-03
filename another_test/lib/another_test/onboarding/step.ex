defmodule AnotherTest.Onboarding.Step do
  @moduledoc """
  This is a data representation of an onboarding step.
  """
  use Ecto.Schema

  embedded_schema do
    field :key, :string
    field :title, :string
  end
end
