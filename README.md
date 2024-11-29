# Subscription Manager Backend

This is a Rails-based backend for managing subscriptions with Stripe, supporting events like subscription creation, cancellation, and payment processing.

## Setup Instructions

### Non-Dockerized Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/royaanane/subscriptions_manager_backend.git
   cd subscriptions_manager_backend
   ```

2. **Install dependencies**:
   Ensure you have Ruby, Rails, and PostgreSQL installed.

   - **Ruby**: Ensure the version specified in `.ruby-version` is installed.
   - **Rails**: Install Rails by running `gem install rails`.

   Install the required gems:
   ```bash
   bundle install
   ```

3. **Create and migrate the database**:
   ```bash
   bin/rails db:create db:migrate
   ```

4. **Configure environment variables**:
   Create a `.env` file in the root of the project and add the following:
   ```plaintext
   STRIPE_SECRET_KEY="sk_…”
   STRIPE_PUBLISHABLE_KEY="pk_…”
   STRIPE_SIGNIN_SECRET="whsec_…”
   ```

5. **Run the Stripe event listeners**:
   You need to run the Stripe CLI to listen for events:
   Open 3 different terminal windows and run the following commands in each:

   ```bash
   stripe listen --events=customer.subscription.created --forward-to http://localhost:3000/stripe_subscriptions
   stripe listen --events=invoice.paid --forward-to http://localhost:3000/stripe_invoices
   stripe listen --events=customer.subscription.deleted --forward-to http://localhost:3000/stripe_subscriptions
   ```

6. **Trigger events in Stripe UI**:
   From your Stripe Dashboard, trigger subscription creation, payment, and deletion to test if it updates the subscription object in the database.

### Dockerized Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/royaanane/subscriptions_manager_backend.git
   cd subscriptions_manager_backend
   ```

2. **Configure environment variables**:
   Create a `.env` file in the root of the project and add the following:
   ```plaintext
   STRIPE_SECRET_KEY="sk_…”
   STRIPE_PUBLISHABLE_KEY="pk_…”
   STRIPE_SIGNIN_SECRET="whsec_…”
   ```

3. **You will see a `docker-compose.yml` file**:
   This file will help you run your services (web app, database, and Stripe listeners) in separate containers. The configuration includes the following services:

   - **web**: Rails application container.
   - **db**: PostgreSQL database container.
   - **stripe-listener-subscription-created**: Stripe listener for subscription creation events.
   - **stripe-listener-invoice-paid**: Stripe listener for invoice payment events.
   - **stripe-listener-subscription-deleted**: Stripe listener for subscription cancellation events.

4. **Build and start the containers**:
   Now that you have the `docker-compose.yml` file, build and start all the containers by running:
   ```bash
   docker-compose up --build
   ```

5. **Trigger events in Stripe UI**:
   From your Stripe Dashboard, trigger subscription creation, payment, and deletion to test if it updates the subscription object in the database.

## Troubleshooting

- If you face any issues related to database connection, ensure that the `db` service is up and running by checking the Docker container logs.
- For any issues with the Stripe CLI listeners, ensure that your `.env` file is correctly configured and that the Stripe CLI is successfully running.

## Docker Commands

- To start all containers:
  ```bash
  docker-compose up
  ```

- To build containers before starting:
  ```bash
  docker-compose up --build
  ```

- To stop all containers:
  ```bash
  docker-compose down
  ```

- To run a specific service (e.g., the web app):
  ```bash
  docker-compose up web
  ```

## Additional Notes

- **Environment Variables**: Make sure to set up your `.env` file as specified to ensure that Stripe works properly.
- **Testing Stripe**: You can simulate Stripe events from the Stripe Dashboard to test whether the webhook listeners and database updates work as expected.

