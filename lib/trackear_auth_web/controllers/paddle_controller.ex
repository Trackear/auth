defmodule TrackearAuthWeb.PaddleController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Billings

  @doc """
  Handle new subscription webhook/event from Paddle.
  This event is only triggered once by Paddle when a
  user creates his/her first subscription.

  See https://developer.paddle.com/webhook-reference/subscription-alerts/subscription-created
  """
  def webhook(conn, %{
      "alert_name"            => alert_name,
      "passthrough"           => passthrough,
      "cancel_url"            => cancel_url,
      "update_url"            => update_url,
      "next_bill_date"        => next_bill_date,
      "status"                => status,
      "subscription_id"       => subscription_id,
      "subscription_plan_id"  => subscription_plan_id,
      "quantity"              => quantity
  })
  when alert_name == "subscription_created"
  do
    # passthrough is data we can set when creating a new subscription.
    # Paddle will then send it back on every webhook/event.
    # In the subscription button, we set it up so we get the following info:
    # passthrough = "{"owner_id":1, "owner_type": "User"}
    # owner_id being the subscriber and owner_type is a value required
    # by the Pay gem https://github.com/pay-rails/pay we originally were using.
    # We are only using owner_type just for compatibility reasons
    with {:ok, %{"owner_id" => owner_id}} <- Poison.decode(passthrough),
         # Parse the next billing date
         {:ok, next_bill_date_parsed} <- NaiveDateTime.from_iso8601(next_bill_date <> " 00:00:00"),
         # Get query params from URL
         %{query_params: params} <- fetch_query_params(conn),
         # Get the secret parameter to make sure it matches the one
         # we configured on .env -> PADDLE_SECRET
         %{"secret" => secret} <- params
    do
      # Fails and terminates execution if it doesn't match
      true = System.get_env("PADDLE_SECRET") == secret

      changeset = %{
        owner_id: owner_id,
        processor_id: subscription_id,
        processor_plan: subscription_plan_id,
        quantity: quantity,
        ends_at: next_bill_date_parsed,
        status: status,
        update_url: update_url,
        cancel_url: cancel_url
      }

      # Fails and terminates execution if record can't be created
      {:ok, _} = Billings.update_or_create_paddle_subscription(changeset)
      text(conn, "OK")
    else
      _ ->
        text(conn, "NOK Invalid passthrough")
    end
  end

  def webhook(conn, %{
    "alert_name"            => alert_name,
    "passthrough"           => passthrough,
    "cancel_url"            => cancel_url,
    "update_url"            => update_url,
    "next_bill_date"        => next_bill_date,
    "status"                => status,
    "subscription_id"       => subscription_id,
    "subscription_plan_id"  => subscription_plan_id,
    "new_quantity"          => new_quantity
  })
  when alert_name == "subscription_updated"
  do
    # Get subscriber from passthrough
    # See first webhook definition for documentation on owner_id & passthrough
    with {:ok, %{"owner_id" => owner_id}} <- Poison.decode(passthrough),
         # Parse the next billing date
         {:ok, next_bill_date_parsed} <- NaiveDateTime.from_iso8601(next_bill_date <> " 00:00:00"),
         # Get query params from URL
         %{query_params: params} <- fetch_query_params(conn),
         # Get the secret parameter to make sure it matches the one
         # we configured on .env -> PADDLE_SECRET
         %{"secret" => secret} <- params
    do
      # Fails and terminates execution if it doesn't match
      true = System.get_env("PADDLE_SECRET") == secret

      changeset = %{
        owner_id: owner_id,
        processor_id: subscription_id,
        processor_plan: subscription_plan_id,
        quantity: new_quantity,
        ends_at: next_bill_date_parsed,
        status: status,
        update_url: update_url,
        cancel_url: cancel_url
      }

      # Fails and terminates execution if record can't be created
      {:ok, _} = Billings.update_or_create_paddle_subscription(changeset)
      text(conn, "OK")
    else
      _ ->
        text(conn, "NOK Invalid passthrough")
    end
  end

  @doc """
  Handle new subscription payment webhook/event from Paddle.
  This event get triggered when the payment for a subscription
  is executed successfully.

  See https://developer.paddle.com/webhook-reference/subscription-alerts/subscription-payment-succeeded
  """
  def webhook(conn, %{
    "alert_name"              => alert_name,
    "passthrough"             => passthrough,
    "next_bill_date"          => next_bill_date,
    "status"                  => status,
    "subscription_id"         => subscription_id,
    "subscription_plan_id"    => subscription_plan_id,
    "subscription_payment_id" => subscription_payment_id,
    "quantity"                => quantity,
    "sale_gross"              => sale_gross,
    "payment_method"          => payment_method,
    "receipt_url"             => receipt_url
  })
  when alert_name == "subscription_payment_succeeded"
  do
    # Get subscriber from passthrough
    # See first webhook definition for documentation on owner_id & passthrough
    with {:ok, %{"owner_id" => owner_id}} <- Poison.decode(passthrough),
        # Parse next billing date
        {:ok, next_bill_date_parsed} <- NaiveDateTime.from_iso8601(next_bill_date <> " 00:00:00"),
        # Get query params from URL
        %{query_params: params} <- fetch_query_params(conn),
        # Get secret parameter so we can later
        # check if matches the one we configured
        # on .env -> PADDLE_SECRET
        %{"secret" => secret} <- params
    do
      # Fails and terminates execution if it doesn't match
      true = System.get_env("PADDLE_SECRET") == secret

      # Fails and terminates execution if amount can't be parsed
      {amount, _} = Integer.parse(sale_gross)

      # Make sure the subscription is created in the database.
      # If, for some reason, the subscription couldn't be created
      # (maybe the event subscription_created was never triggered or it failed)
      # make sure the subscription gets created in our database.
      # Get the subscription or fail terminating the execution
      {:ok, subscription} = Billings.update_or_create_paddle_subscription(%{
        owner_id: owner_id,
        processor_id: subscription_id,
        processor_plan: subscription_plan_id,
        quantity: quantity,
        ends_at: next_bill_date_parsed,
        status: status
      })

      changeset = %{
        owner_id: owner_id,
        processor_id: subscription_payment_id,
        amount: amount * 100,
        card_type: payment_method,
        receipt_url: receipt_url
      }

      # Fails and terminates execution if record can't be created
      {:ok, _} = Billings.create_paddle_charge(changeset)
      text(conn, "OK")
    else
      _ ->
        text(conn, "NOK Invalid passthrough")
    end
  end

  # Answer with 200 OK for unhandled events
  # coming from Paddle. This way, Paddle won't
  # keep executing the webhook/event (if they receive
  # other than 200 they keep retrying)
  # See https://developer.paddle.com/webhook-reference/intro
  def webhook(conn, _) do
    text(conn, "NOK")
  end
end
