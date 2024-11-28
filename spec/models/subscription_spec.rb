require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:stripe_subscription_id) }
    it { should validate_uniqueness_of(:stripe_subscription_id) }
  end
end
