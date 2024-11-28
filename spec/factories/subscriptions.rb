FactoryBot.define do
  factory :subscription do
    stripe_subscription_id { "STRIPE_SUBSCRIPTION_ID" }
    state { "unpaid" }
  end
end
