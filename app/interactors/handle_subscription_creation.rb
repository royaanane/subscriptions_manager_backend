class HandleSubscriptionCreation
  include Interactor

  def call
    event = context.event
    subscription = event.data.object

    begin
      Subscription.create!(stripe_subscription_id: subscription.id, state: :unpaid)
      context.status = :created
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(error: "Error processing subscription created event", details: e.message)
    rescue ActiveRecord::RecordNotUnique => e
      context.fail!(error: "Subscription already exists for Stripe Subscription ID", details: e.message)
    end
  end
end
