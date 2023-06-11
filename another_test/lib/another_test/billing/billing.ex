defmodule AnotherTest.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  import AnotherTest.Billing.NormalizeAttributes

  alias AnotherTest.Repo
  alias AnotherTest.Billing.Stripe.Customer
  alias AnotherTest.Billing.Stripe.Subscription
  alias AnotherTest.Billing.Stripe.Plan
  alias AnotherTest.Billing.Stripe.Product
  alias AnotherTest.Billing.Stripe.Invoice
  alias AnotherTest.Accounts.Membership

  @schemas [Customer, Subscription, Plan, Product, Invoice]

  def list_products_and_plans_for_pricing_page(interval \\ "month") do
    from(p in Plan,
      join: pr in assoc(p, :product),
      preload: [:product],
      where: pr.active == true,
      where: p.interval == ^interval,
      order_by: [:amount]
    )
    |> Repo.all()
  end

  defp base_query(schema, opts) when schema in @schemas do
    preload = Keyword.get(opts, :preload, [])
    where = Keyword.get(opts, :where, [])
    order_by = Keyword.get(opts, :order_by, [])

    from(s in schema,
      where: ^where,
      preload: ^preload,
      order_by: ^order_by
    )
  end

  @doc """
  Returns the paginated list of subscriptions.

  ## Examples

      iex> paginate_subscriptions(%{})
      %{entries: [%Subscription{}, ...]}

  """
  def paginate_subscriptions(params \\ %{}) do
    Flop.validate_and_run(Subscription, params, for: Subscription)
  end

  @doc """
  Gets a single subscription.

  Returns nil if the record does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      nil

  """
  def get_subscription!(id) do
    Repo.get!(Subscription, id)
  end

  @doc """
  Returns the list of records for the given schema.

  ## Examples

      iex> list_records()
      [%SchemaDefinition{}, ...]

  """
  def list_records(schema, opts \\ []) when schema in @schemas do
    base_query(schema, opts)
    |> Repo.all()
  end

  @doc """
  Gets a single record by remote_id for a given schema.

  Returns nil if the record does not exist.

  ## Examples

      iex> get_record(123)
      %SchemaDefinition{}

      iex> get_record(456)
      nil

  """
  def get_record(schema, remote_id, opts \\ []) when schema in @schemas do
    base_query(schema, opts)
    |> Repo.get_by(remote_id: remote_id)
  end

  @doc """
  Updates a users customer with remote customer attributes.

  ## Examples

      iex> update_customer(customer, %{field: value})
      {:ok, %Customer{}}

      iex> update_customer(Subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{remote_id: nil} = customer, %Stripe.Customer{} = attrs) do
    attrs = to_attrs(attrs)
    update_customer(customer, attrs)
  end

  def update_customer(%Customer{} = customer, attrs) when is_struct(attrs) do
    attrs = to_attrs(attrs) |> Map.drop([:remote_id])
    update_customer(customer, attrs)
  end

  def update_customer(%Customer{} = customer, attrs) when is_map(attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Creates or update record for a given schema.

  ## Examples

      iex> create_or_update(Subscription, %{field: value})
      {:ok, %SchemaDefinition{}}

      iex> create_or_update(Subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_update(schema, attrs) when schema in @schemas and schema != Customer do
    %{remote_id: remote_id} = attrs = to_attrs(attrs)

    case Repo.get_by(schema, remote_id: remote_id) do
      nil ->
        schema.new()
        |> schema.changeset(attrs)
        |> Repo.insert()

      record ->
        record
        |> schema.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Deletes a record for a given schema.

  ## Examples

      iex> delete_record(subscription)
      {:ok, %Subscription{}}

      iex> delete_record(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_record(%schema{} = record) when schema in [Product, Plan] do
    Repo.delete(record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_record(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_record(%schema{} = record, attrs \\ %{}) when schema in @schemas do
    schema.changeset(record, attrs)
  end

  @doc """
  Gets a single active subscription for a account_id.

  Returns `nil` if an active Subscription does not exist.

  ## Examples

      iex> get_active_subscription_for_account(123)
      %Subscription{}

      iex> get_active_subscription_for_account(456)
      nil

  """
  def get_active_subscription_for_account(account) do
    with %Customer{} = customer <- get_billing_customer_for_account(account),
         %Subscription{} = subscription <- get_active_subscription_for_customer(customer) do
      subscription
    else
      _ ->
        nil
    end
  end

  @doc """
  Gets a single active subscription for a billing customer.

  Returns `nil` if an active Subscription does not exist.

  ## Examples

      iex> get_active_subscription_for_customer(123)
      %Subscription{}

      iex> get_active_subscription_for_customer(456)
      nil

  """
  def get_active_subscription_for_customer(customer) do
    from(s in Subscription,
      join: c in assoc(s, :customer),
      where: c.id == ^customer.id,
      where: is_nil(s.cancel_at) or s.cancel_at > ^NaiveDateTime.utc_now(),
      where: s.current_period_end_at > ^NaiveDateTime.utc_now(),
      where: s.status == "active",
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Gets a customer for a user.

  returns nil if the Customer does not exist.

  ## Examples

      iex> get_billing_customer_for_user(123)
      %Customer{}

      iex> get_billing_customer_for_user(456)
      nil

  """
  def get_billing_customer_for_user(user) do
    Repo.get_by!(Customer, id: user.id)
  end

  @doc """
  Gets a single customer for a account_id.

  Returns nil if the Customer does not exist.

  ## Examples

      iex> get_billing_customer_for_account(%Account{id: 123})
      %Customer{}

      iex> get_billing_customer_for_account(%Account{id: 456})
      nil

  """
  def get_billing_customer_for_account(%{personal: true, created_by_user_id: id}) do
    Repo.get!(Customer, id)
  end

  def get_billing_customer_for_account(account) do
    membership =
      from(m in Membership,
        where: m.account_id == ^account.id,
        where: m.billing_customer == true
      )
      |> Repo.one(account_id: account.id)

    case membership do
      nil -> nil
      %{user_id: id} -> Repo.get!(Customer, id)
    end
  end
end
