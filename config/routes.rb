Rails.application.routes.draw do
  resources :stripe_subscriptions, controller: "stripe_subscriptions_webhooks", only: :create
  resources :stripe_invoices, controller: "stripe_invoices_webhooks", only: :create
end
