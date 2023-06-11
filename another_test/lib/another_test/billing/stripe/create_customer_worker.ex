defmodule AnotherTest.Billing.Stripe.CreateCustomerWorker do
  @moduledoc """
  The worker is called when a user has registered from the users context.
  """
  use Oban.Worker

  import AnotherTest.Billing.Stripe.StripeService

  alias AnotherTest.Repo
  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Customer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    customer = Repo.get(Customer, id)

    if is_nil(customer.remote_id) do
      {:ok, customer_object} = stripe_service(:create_customer, args: %{email: customer.email})
      Billing.update_customer(customer, customer_object)
    end

    :ok
  end
end
