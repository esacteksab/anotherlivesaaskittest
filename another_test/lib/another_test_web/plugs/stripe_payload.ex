defmodule AnotherTestWeb.Plugs.StripePayload do
  @moduledoc """
  This plug is needed for getting the raw unparsed body and add it to assigns.
  It is used for comparing Stripe signature in the Stripe Webhook Controller
  """
  import Plug.Conn, only: [get_req_header: 2, assign: 3, read_body: 1]

  def init(options), do: options

  def call(conn, _opts) do
    case get_stripe_signature(conn) do
      [] ->
        conn

      ["" <> stripe_signature] ->
        {:ok, raw_body, _conn} = read_body(conn)

        conn
        |> assign(:raw_body, raw_body)
        |> assign(:stripe_signature, stripe_signature)
    end
  end

  defp get_stripe_signature(conn) do
    # NOTE: I have seen both examples so I will look for either or
    get_req_header(conn, "stripe-signature") ++ get_req_header(conn, "Stripe-Signature")
  end
end
