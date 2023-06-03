defmodule AnotherTest.Schema do
  @moduledoc """
  This module can be included in Schema file and used
  like `use AnotherTest.Schema` instead of `use Ecto.Schema`.
  That makes is possible to remove the specification about key type.
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end
