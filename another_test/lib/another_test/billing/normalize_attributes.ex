defmodule AnotherTest.Billing.NormalizeAttributes do
  @moduledoc """
  Normalize attributes from external data sources like Stripe
  so it fits a more generalized schema
  """

  def to_attrs(%Stripe.Customer{id: id} = customer) do
    %{
      remote_id: id,
      billing_email: customer.email,
    }
  end

  def to_attrs(%Stripe.PaymentMethod{card: card} = _payment_method) do
    %{
      card_brand: card.brand,
      card_exp_month: card.exp_month,
      card_exp_year: card.exp_year,
      card_last4: card.last4,
    }
  end

  def to_attrs(%Stripe.Subscription{id: id} = subscription) do
    %{
      remote_id: id,
      status: subscription.status,
      cancel_at: subscription.cancel_at,
      canceled_at: subscription.canceled_at,
      current_period_end_at: subscription.current_period_end,
      current_period_start: subscription.current_period_start,
      remote_customer_id: subscription.customer,
      remote_plan_id: subscription.plan.id,
    }
  end

  def to_attrs(%Stripe.Plan{id: id} = plan) do
    %{
      remote_id: id,
      remote_product_id: plan.product,
      active: plan.active,
      amount: plan.amount,
      currency: plan.currency,
      interval: plan.interval,
      interval_count: plan.interval_count,
      usage_type: plan.usage_type,
      trial_period_days: plan.trial_period_days,
      name: plan.name,
    }
  end

  def to_attrs(%Stripe.Product{id: id} = product) do
    %{
      remote_id: id,
      active: product.active,
      name: product.name,
      description: product.description,
    }
  end

  def to_attrs(%Stripe.Invoice{id: id} = invoice) do
    %{
      remote_id: id,
      remote_customer_id: invoice.customer,
      status: invoice.status,
      subtotal: invoice.subtotal,
      hosted_invoice_url: invoice.hosted_invoice_url,
      invoice_pdf: invoice.invoice_pdf,
    }
  end

  def to_attrs(attrs), do: attrs # fallback
end
