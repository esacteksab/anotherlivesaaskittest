defmodule AnotherTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AnotherTestWeb.Telemetry,
      # Start the Ecto repository
      AnotherTest.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AnotherTest.PubSub},
      # Start Finch
      {Finch, name: AnotherTest.Finch},
      # Start the Endpoint (http/https)
      AnotherTestWeb.Endpoint,
      # Start a worker by calling: AnotherTest.Worker.start_link(arg)
      # {AnotherTest.Worker, arg}
      webhook_processor_service(),
      {Oban, oban_config()},
      # You can add additional caches with different names
      {Cachex, name: :general_cache}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AnotherTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AnotherTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.fetch_env!(:another_test, Oban)
  end

  # Dont start the genserver in test mode
  defp webhook_processor_service do
    if Application.get_env(:another_test, :env) == :test,
      do: AnotherTest.Billing.Stripe.WebhookProcessor.Stub,
      else: AnotherTest.Billing.Stripe.WebhookProcessor
  end
end
