class StripeSubscriptionsWebhooksController < StripeWebhooksController
  def create
    event = Stripe::Event.construct_from(params.as_json)
    handler = handler_for(event.type)

    if handler
      result = handler.call(event: event)

      if result.success?
        render json: { message: "Event processed successfully" }, status: result.status
      else
        render json: { error: result.error, details: result.details }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid event type" }, status: :bad_request
    end
  end

  private

    def handler_for(event_type)
      {
        STRIPE_WEBHOOK_EVENTS[:subscription_created] => HandleSubscriptionCreation,
        STRIPE_WEBHOOK_EVENTS[:subscription_canceled] => HandleSubscriptionCancellation
      }[event_type]
    end
end
