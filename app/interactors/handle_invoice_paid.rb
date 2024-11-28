class HandleInvoicePaid
  include Interactor

  def call
    subscription = Subscription.find_by!(stripe_subscription_id: context.subscription_id)

    if subscription.paid?
      context.fail!(error: "Subscription already paid", status: :unprocessable_entity)
    end

    subscription.update!(state: :paid)
  rescue ActiveRecord::RecordNotFound => e
    context.fail!(error: "Subscription not found", status: :not_found)
  end
end
