require "rails_helper"

RSpec.describe HandleSubscriptionCreation, type: :interactor do
  describe ".call" do
    let(:event) do
      double("Stripe::Event", data: OpenStruct.new(object: double("Subscription", id: "sub_SOME_ID")))
    end

    context "when the subscription is created successfully" do
      it "creates a subscription with state 'unpaid'" do
        expect(Subscription).to receive(:create!).with(stripe_subscription_id: "sub_SOME_ID", state: :unpaid)

        result = HandleSubscriptionCreation.call(event: event)

        expect(result).to be_success
      end
    end

    context "when the subscription already exists" do
      it "fails with a record not unique error message" do
        allow(Subscription).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique.new("Duplicate entry"))

        result = HandleSubscriptionCreation.call(event: event)

        expect(result).to be_failure
        expect(result.error).to eq("Subscription already exists for Stripe Subscription ID")
        expect(result.details).to eq("Duplicate entry")
      end
    end

    context "when the subscription creation fails" do
      it "fails with a record invalid error message" do
        allow(Subscription).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

        result = HandleSubscriptionCreation.call(event: event)

        expect(result).to be_failure
        expect(result.error).to eq("Error processing subscription created event")
        expect(result.details).to eq("Record invalid")
      end
    end
  end
end
