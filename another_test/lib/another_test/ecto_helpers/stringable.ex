defmodule AnotherTest.EctoHelpers.Stringable do
  @moduledoc """
  This module is a custom ecto type that casts the input
  to a string before storing it in the database.
  """
  use Ecto.Type

  def type, do: :string

  def cast(string) when is_binary(string), do: {:ok, string}

  def cast(val) do
    if String.Chars.impl_for(val) do
      {:ok, to_string(val)}
    else
      {:error, "cannot convert to string"}
    end
  end

  def dump(string), do: {:ok, string}

  def load(string), do: {:ok, string}
end
