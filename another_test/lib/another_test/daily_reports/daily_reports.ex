defmodule AnotherTest.DailyReports do
  @moduledoc """
  This module is reponsible for producing data about
  x number of records that was stored in the database yesterday
  for different schemas or tables.
  """
  import Ecto.Query, warn: false
  alias AnotherTest.Repo

  # {AnotherTest.Users.User, :inserted_at},
  # {"accounts", :inserted_at},
  defp aggregators do
    [
      {AnotherTest.Users.User, :inserted_at}
    ]
  end

  @doc """
  Return a list of tuples like:

      [{"users", :inserted_at, 0}, {"accounts", :inserted_at, 0}]
  """
  def perform_queries do
    aggregators()
    |> Enum.map(fn
      {schema, field} ->
        {to_name(schema), field, aggregate(schema, field)}
    end)
  end

  # Count number of records that occured yesterday based on the
  # field
  defp aggregate(schema, field) when is_atom(field) do
    from(
      q in schema,
      where: fragment("?::date", field(q, ^field)) == date_add(^Date.utc_today(), -1, "day")
    )
    |> Repo.aggregate(:count, field, skip_account_id: true)
  end

  # Return the table name as a string of the schema name
  defp to_name("" <> schema) do
    schema
  end

  defp to_name(schema) do
    schema.__schema__(:source)
  end
end
