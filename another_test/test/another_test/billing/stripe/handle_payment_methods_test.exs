defmodule AnotherTest.Billing.HandlePaymentMethodsTest do
  use AnotherTest.DataCase, async: true

  import AnotherTest.BillingFixtures

  alias AnotherTest.Billing
  alias AnotherTest.Billing.Stripe.Customer
  alias AnotherTest.Billing.Stripe.HandlePaymentMethods

  describe "add_card_info" do
    setup [:setup_customer]

    test "add_card_info/1 adds card data to account", %{customer: customer} do
      payment_method = payment_method_data(%{customer: customer.remote_id})

      HandlePaymentMethods.add_card_info(payment_method)

      assert customer = Billing.get_record(Customer, customer.remote_id)
      assert customer.card_brand == "visa"
      assert customer.card_last4 == "4242"
      assert customer.card_exp_year == 2024
      assert customer.card_exp_month == 4
    end
  end

  describe "remove_card_info" do
    setup [:setup_customer_with_info]

    test "remove_card_info/1 adds card data to account", %{customer: customer} do
      assert customer.card_brand == "visa"
      assert customer.card_last4 == "1234"

      payment_method = payment_method_data(%{customer: customer.remote_id})

      HandlePaymentMethods.remove_card_info(payment_method)

      assert customer = Billing.get_record(Customer, customer.remote_id)
      assert customer.card_brand == nil
      assert customer.card_last4 == nil
      assert customer.card_exp_year == nil
      assert customer.card_exp_month == nil
    end
  end

  defp setup_customer(_) do
    {:ok, customer} = customer_fixture() |> Billing.update_customer(%{
        card_brand: nil,
        card_last4: nil,
        card_exp_year: nil,
        card_exp_month: nil
      })
    %{customer: customer}
  end

  defp setup_customer_with_info(_) do
    {:ok, customer} = customer_fixture() |> Billing.update_customer(%{
      card_brand: "visa",
      card_last4: "1234",
      card_exp_year: 25,
      card_exp_month: 12
    })

    %{customer: customer}
  end

  defp payment_method_data(attrs) do
    %Stripe.PaymentMethod{
      card: %{
        brand: "visa",
        checks: %{
          address_line1_check: nil,
          address_postal_code_check: "pass",
          cvc_check: "pass"
        },
        country: "US",
        exp_month: 4,
        exp_year: 2024,
        fingerprint: "6i0wEjVDGBrgOQhe",
        funding: "credit",
        generated_from: nil,
        last4: "4242",
        networks: %{available: ["visa"], preferred: nil},
        three_d_secure_usage: %{supported: true},
        wallet: nil
      },
      created: 1_617_815_558,
      customer: unique_remote_id(),
      id: unique_remote_id(),
      livemode: false,
      metadata: %{},
      object: "payment_method",
      type: "card"
    }
    |> Map.merge(attrs)
  end
end
