defmodule AnotherTest.Repo do
  @moduledoc """
  Mofified Repo to allow multi tennancy and require that account_id is
  set if the table has an account_id field.
  """
  use Ecto.Repo,
    otp_app: :another_test,
    adapter: Ecto.Adapters.Postgres

  require Ecto.Query

  # The idea here is that most - if not all - resources in
  # the system belong to a tenant. The tenant is typically
  # an organization or a user and all resources have an
  # account_id (or user_id ) foreign key pointing directly to it.

  def prepare_query(_operation, query, opts) do
    cond do
      opts[:schema_migration] ->
        {query, opts}

      has_account_id?(query) == false ->
        {query, opts}

      opts[:skip_account_id] ->
        {query, opts}

      account_id = opts[:account_id] ->
        {Ecto.Query.where(query, account_id: ^account_id), opts}

      true ->
        raise "expected account_id or skip_account_id to be set"
    end
  end

  @tenant_key {__MODULE__, :account_id}

  def put_account_id(account_id) do
    Process.put(@tenant_key, account_id)
  end

  def get_account_id() do
    Process.get(@tenant_key)
  end

  # This is used for some requests like Pow create session
  # Its used in a custom Plug `SkipAccountIdCheck` and
  # in a `refute_current_user` pipeline
  @skip_account_id_key {__MODULE__, :skip_account_id}

  def put_skip_account_id(skip_account_id \\ true) do
    Process.put(@skip_account_id_key, skip_account_id)
  end

  def get_skip_account_id() do
    Process.get(@skip_account_id_key)
  end

  def default_options(_operation) do
    [account_id: get_account_id(), skip_account_id: get_skip_account_id()]
  end

  defp has_account_id?(%{from: %{source: {_table, nil}}}), do: false

  defp has_account_id?(%{from: %{source: {_table, module}}}) do
    module.__schema__(:fields)
    |> Enum.member?(:account_id)
  end

  defp has_account_id?(_), do: false
end
