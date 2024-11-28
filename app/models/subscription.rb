class Subscription < ApplicationRecord
  SUBSCRIPTION_STATES = {
    unpaid: 0,
    paid: 1,
    canceled: 2
  }.freeze

  enum :state, SUBSCRIPTION_STATES

  validates :stripe_subscription_id, presence: true, uniqueness: true
end
