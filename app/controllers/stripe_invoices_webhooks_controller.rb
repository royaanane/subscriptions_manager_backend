class StripeInvoicesWebhooksController < StripeWebhooksController
  def create
    if params[:type] != STRIPE_WEBHOOK_EVENTS[:invoice_paid]
      render json: { error: "Invalid event type" }, status: :bad_request
      return
    end

    context = HandleInvoicePaid.call(subscription_id: invoice_params[:subscription])

    if context.failure?
      error_response(context.error, context.status)
    else
      head :ok
    end
  end

  private

  def invoice_params
    params.require(:data).require(:object)
  end

  def error_response(message, status)
    render json: { error: message }, status: status
  end
end
