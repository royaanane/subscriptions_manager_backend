require 'rails_helper'

RSpec.describe HandleInvoicePaid, type: :interactor do
  let!(:subscription) do
    Subscription.create!(stripe_subscription_id: 'sub_SOME_ID', state: :unpaid)
  end

  describe '.call' do
    context 'when subscription is found' do
      it 'updates the subscription state to paid' do
        result = HandleInvoicePaid.call(subscription_id: subscription.stripe_subscription_id)

        expect(result).to be_success
        expect(subscription.reload.state).to eq('paid')
      end
    end

    context 'when subscription is not found' do
      it 'fails and provides a meaningful error' do
        result = HandleInvoicePaid.call(subscription_id: 'non_existent_id')

        expect(result).to be_failure
        expect(result.error).to eq('Subscription not found')
      end
    end

    context 'when subscription is already paid' do
      it 'fails and provides a meaningful error' do
        subscription.update!(state: :paid)

        result = HandleInvoicePaid.call(subscription_id: subscription.stripe_subscription_id)

        expect(result).to be_failure
        expect(result.error).to eq('Subscription already paid')
      end
    end
  end
end
