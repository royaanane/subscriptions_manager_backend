require 'rails_helper'

RSpec.describe 'StripeInvoicesWebhooks', type: :request do
  describe 'Create' do
    context 'Create' do
      let(:headers) do
        { 'Content-Type' => 'application/json' }
      end
      let(:payload) do
        {
          type: 'invoice.paid',
          data: {
            object: {
              subscription: 'sub_SOME_ID'
            }
          }
        }
      end

      context 'Stripe Signature is verified' do
        before do
          allow(Stripe::Webhook).to receive(:construct_event).and_return('dummy_event_type')
        end

        context 'when the event is different from invoice.paid' do
          it 'returns a bad request response' do
            payload[:type] = 'invoice.created'

            post '/stripe_invoices', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'when the subscription related to the invoice exists' do
          let!(:subscription) { Subscription.create!(stripe_subscription_id: 'sub_SOME_ID', state: :unpaid) }

          it 'returns a success response and updates the state to paid' do
            post '/stripe_invoices', headers: headers, params: payload.to_json

            expect(subscription.stripe_subscription_id).to eq('sub_SOME_ID')
            expect(subscription.reload.state).to eq('paid')
            expect(response).to have_http_status(:ok)
          end
        end

        context 'when subscription does not exist' do
          it 'returns not found response' do
            payload[:type] = 'invoice.paid'

            post '/stripe_invoices', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:not_found)
          end
        end

        context 'when subscription is already paid' do
          let!(:subscription) { Subscription.create!(stripe_subscription_id: 'sub_SOME_ID', state: :paid) }

          it 'returns unprocessable entity response' do
            post '/stripe_invoices', headers: headers, params: payload.to_json

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
