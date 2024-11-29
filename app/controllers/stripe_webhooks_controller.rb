class StripeWebhooksController < ActionController::Base
  before_action :check_stripe_signature

  STRIPE_WEBHOOK_EVENTS = {
    subscription_created: "customer.subscription.created",
    invoice_paid: "invoice.paid",
    subscription_canceled: "customer.subscription.deleted"
  }

  private

  def check_stripe_signature
    payload = request.body.read
    signature_header = request.env["HTTP_STRIPE_SIGNATURE"]
    signin_secret = ENV["STRIPE_SIGNIN_SECRET"]

    begin
      Stripe::Webhook.construct_event(payload, signature_header, signin_secret)
    rescue JSON::ParserError
      render json: { error: "Invalid JSON payload" }, status: :bad_request
    rescue Stripe::SignatureVerificationError
      render json: { error: "Invalid signature" }, status: :forbidden
    rescue Stripe::InvalidRequestError => e
      render json: { error: "Invalid request: #{e.message}" }, status: :bad_request
    rescue Stripe::AuthenticationError => e
      render json: { error: "Authentication error: #{e.message}" }, status: :unauthorized
    rescue Stripe::APIConnectionError => e
      render json: { error: "Network communication error: #{e.message}" }, status: :service_unavailable
    rescue Stripe::StripeError => e
      render json: { error: "Stripe error: #{e.message}" }, status: :internal_server_error
    end
  end
end
