class StripeSubscriptionsWebhooksController < StripeWebhooksController
  def create
    event = Stripe::Event.construct_from(params.as_json)

    if event.type == STRIPE_WEBHOOK_EVENTS[:subscription_created]
      handle_subscription_created(event)
    else
      render json: { error: "Invalid event type" }, status: :bad_request
    end
  end

  private

  def handle_subscription_created(event)
    result = HandleSubscriptionCreation.call(event: event)

    if result.success?
      head :created
    else
      render json: { error: result.error, details: result.details }, status: :unprocessable_entity
    end
  end
end
