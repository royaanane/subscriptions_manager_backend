require "rails_helper"

RSpec.describe HandleSubscriptionCancellation, type: :interactor do
  describe ".call" do
    let(:event) do
      double("Stripe::Event", data: OpenStruct.new(object: double("Subscription", id: "sub_SOME_ID")))
    end

    context "when the subscription is canceled successfully" do
      let!(:subscription) { Subscription.create!(stripe_subscription_id: "sub_SOME_ID", state: :paid) }

      it "cancels the subscription" do
        result = HandleSubscriptionCancellation.call(event: event)

        expect(result).to be_success
        expect(subscription.reload.state).to eq("canceled")
      end
    end

    context "when the subscription does not exist" do
      it "fails with a not found error message" do
        result = HandleSubscriptionCancellation.call(event: event)

        expect(result).to be_failure
        expect(result.error).to eq("Subscription with ID sub_SOME_ID not found")
        expect(result.status).to eq(:not_found)
      end
    end

    context "when the subscription is already canceled" do
      let!(:subscription) { Subscription.create!(stripe_subscription_id: "sub_SOME_ID", state: :canceled) }

      it "fails with an unprocessable entity error message" do
        result = HandleSubscriptionCancellation.call(event: event)

        expect(result).to be_failure
        expect(result.error).to eq("Subscription is already canceled")
        expect(result.status).to eq(:unprocessable_entity)
      end
    end

    context "when the subscription is unpaid" do
      let!(:subscription) { Subscription.create!(stripe_subscription_id: "sub_SOME_ID", state: :unpaid) }

      it "fails with an unprocessable entity error message" do
        result = HandleSubscriptionCancellation.call(event: event)

        expect(result).to be_failure
        expect(result.error).to eq("Unpaid subscriptions cannot be canceled")
        expect(result.status).to eq(:unprocessable_entity)
      end
    end
  end
end
