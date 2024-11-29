class HandleSubscriptionCancellation
  include Interactor

  def call
    event = context.event
    stripe_subscription_id = event.data.object.id

    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription_id)

    if subscription.nil?
      context.fail!(error: "Subscription with ID #{stripe_subscription_id} not found", status: :not_found)
    end

    if subscription.canceled?
      context.fail!(error: "Subscription is already canceled", status: :unprocessable_entity)
    end

    if subscription.unpaid?
      context.fail!(error: "Unpaid subscriptions cannot be canceled", status: :unprocessable_entity)
    end

    subscription.update!(state: :canceled)
    context.status = :ok
  rescue ActiveRecord::RecordInvalid => e
    context.fail!(error: "Failed to cancel subscription: #{e.message}", status: :unprocessable_entity)
  end
end
