export const InitStripeCheckout = {
  mounted() {
    let stripe = Stripe(this.el.dataset.publicKey)

    this.handleEvent('stripe-session', data => {
      stripe.redirectToCheckout({ sessionId: data.stripe_session_id })
    })
  },
}
