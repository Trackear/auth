defmodule TrackearAuthWeb.PaddleController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Billings

  def webhook(conn, %{
      "alert_name"            => alert_name,
      "passthrough"           => passthrough,
      "cancel_url"            => cancel_url,
      "update_url"            => update_url,
      "next_bill_date"        => next_bill_date,
      "status"                => status,
      "subscription_id"       => subscription_id,
      "subscription_plan_id"  => subscription_plan_id
  })
  when alert_name == "subscription_created"
  when status == "active"
  do
    with {:ok, %{"owner_id" => owner_id}} <- Poison.decode(passthrough),
         {:ok, next_bill_date_parsed} <- NaiveDateTime.from_iso8601(next_bill_date <> " 00:00:00"),
         %{query_params: params} <- fetch_query_params(conn),
         %{"secret" => secret} <- params
    do
      # If secret doesn't match, fail loudly!
      true = System.get_env("PADDLE_SECRET") == secret

      changeset = %{
        owner_type: "User",
        owner_id: owner_id,
        name: "default",
        processor: "paddle",
        processor_id: subscription_id,
        processor_plan: subscription_plan_id,
        quantity: 1,
        ends_at: next_bill_date_parsed,
        created_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now(),
        status: status,
        update_url: update_url,
        cancel_url: cancel_url
      }

      {:ok, _} = Billings.create_subscription(changeset)
      text(conn, "OK")
    else
      _ ->
        text(conn, "NOK Invalid passthrough")
    end
  end

  def webhook(conn, _) do
    text(conn, "NOK")
  end
end
