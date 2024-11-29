require 'rails_helper'

RSpec.describe 'StripeSubscriptionsWebhooks', type: :request do
  describe 'Create' do
    let(:headers) { { 'Content-Type' => 'application/json' } }
    context 'when a Stripe subscription is created' do
      let(:payload) do
        {
          type: 'customer.subscription.created',
          data: {
            object: {
              id: 'sub_SOME_ID',
              object: 'subscription'
            }
          }
        }
      end

      context 'when Stripe signature is verified' do
        before do
          allow(Stripe::Webhook).to receive(:construct_event).and_return('dummy_event')
        end

        context 'when the request is valid and the subscription is created' do
          before do
            allow(HandleSubscriptionCreation).to receive(:call).and_return(double(success?: true, status: :created))
          end

          it 'returns a created response (201)' do
            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:created)
          end
        end

        context 'when the event type is not customer.subscription.created' do
          it 'returns a bad request error (400)' do
            payload[:type] = 'invoice.payment_failed'

            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:bad_request)
            json_response = JSON.parse(response.body)
            expect(json_response['error']).to eq("Invalid event type")
          end
        end

        context 'when there is an error during subscription creation' do
          it 'returns an unprocessable entity response (422) and includes an error message' do
            allow(HandleSubscriptionCreation).to receive(:call).and_return(double(success?: false, error: "Error processing subscription created event", details: "Record invalid"))

            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:unprocessable_entity)
            json_response = JSON.parse(response.body)
            expect(json_response['error']).to eq("Error processing subscription created event")
            expect(json_response['details']).to eq("Record invalid")
          end
        end

        context 'when the subscription already exists (e.g., RecordNotUnique error)' do
          it 'returns an unprocessable entity response (422) with a specific error message' do
            allow(HandleSubscriptionCreation).to receive(:call).and_return(double(success?: false, error: "Subscription already exists for Stripe Subscription ID", details: "Subscription already exists"))

            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:unprocessable_entity)
            json_response = JSON.parse(response.body)
            expect(json_response['error']).to eq("Subscription already exists for Stripe Subscription ID")
            expect(json_response['details']).to eq("Subscription already exists")
          end
        end

        context 'when there is an unexpected error' do
          it 'returns an unprocessable entity error (422)' do
            allow(HandleSubscriptionCreation).to receive(:call).and_return(double(success?: false, error: "Internal server error", details: "Something went wrong"))

            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:unprocessable_entity)
            json_response = JSON.parse(response.body)
            expect(json_response['error']).to eq("Internal server error")
            expect(json_response['details']).to eq("Something went wrong")
          end
        end
      end

      context 'when Stripe signature is not verified' do
        it 'returns a forbidden response (403) with an error message' do
          post '/stripe_subscriptions', headers: headers, params: payload.to_json

          expect(response).to have_http_status(:forbidden)
          expect(response.body).to include("Invalid signature")
        end
      end

      context 'when the payload is not valid JSON' do
        it 'returns a bad request response (400) with an error message' do
          allow(Stripe::Webhook).to receive(:construct_event).and_raise(JSON::ParserError)

          post '/stripe_subscriptions', headers: headers, params: payload.to_json

          expect(response).to have_http_status(:bad_request)
          expect(response.body).to include("Invalid JSON payload")
        end
      end
    end

    context 'when a Stripe subscription is canceled' do
      let(:payload) do
        {
          type: 'customer.subscription.deleted',
          data: {
            object: {
              id: 'sub_SOME_ID',
              object: 'subscription'
            }
          }
        }
      end

      context 'when Stripe signature is verified' do
        before do
          allow(Stripe::Webhook).to receive(:construct_event).and_return('dummy_event')
        end

        context 'when the request is valid and the subscription is canceled' do
          before do
            allow(HandleSubscriptionCancellation).to receive(:call).and_return(double(success?: true, status: :ok))
          end

          it 'returns a created response (201)' do
            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:ok)
          end
        end

        context 'when the event type is not customer.subscription.deleted' do
          it 'returns a bad request error (400)' do
            payload[:type] = 'invoice.payment_failed'

            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:bad_request)
            json_response = JSON.parse(response.body)
            expect(json_response['error']).to eq("Invalid event type")
          end
        end

        context 'when there is an error during subscription cancellation' do
          it 'returns an unprocessable entity response (422) and includes an error message' do
            allow(HandleSubscriptionCancellation).to receive(:call).and_return(double(success?: false, error: "Error processing subscription canceled event", details: "Record invalid"))

            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:unprocessable_entity)
            json_response = JSON.parse(response.body)
            expect(json_response['error']).to eq("Error processing subscription canceled event")
            expect(json_response['details']).to eq("Record invalid")
          end
        end

        context 'when the subscription does not exist (e.g., RecordNotFound error)' do
          it 'returns an unprocessable entity response (422) with a specific error message' do
            allow(HandleSubscriptionCancellation).to receive(:call).and_return(double(success?: false, error: "Subscription not found", details: "Subscription does not exist"))

            post '/stripe_subscriptions', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:unprocessable_entity)
            json_response = JSON.parse(response.body)
            expect(json_response['error']).to eq("Subscription not found")
            expect(json_response['details']).to eq("Subscription does not exist")
          end
        end
      end
    end
  end
end
