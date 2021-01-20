defmodule TrackearAuth.Billings do
  @moduledoc """
  The Billings context.
  """

  import Ecto.Query, warn: false
  alias TrackearAuth.Repo

  alias TrackearAuth.Billings.Subscription

  @doc """
  Returns the list of pay_subscriptions.

  ## Examples

      iex> list_pay_subscriptions()
      [%Subscription{}, ...]

  """
  def list_pay_subscriptions do
    Repo.all(Subscription)
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  @doc """
  Gets a subscription from Paddle by using the service
  api/2.0/subscription/users. Only the first result from response will
  be returned (there shouldn't be more than one with the same id)

  See https://developer.paddle.com/api-reference/subscription-api/users/listusers

  ## Examples

      iex> get_subscription_from_paddle(123)
      %{}

      iex> get_subscription_from_paddle(456)
      nil

  """
  def get_subscription_from_paddle(id) do
    paddle_service = "https://vendors.paddle.com/api/2.0/subscription/users"
    payload = %{
      vendor_id: System.get_env("PADDLE_VENDOR_ID"),
      vendor_auth_code: System.get_env("PADDLE_VENDOR_AUTH_CODE"),
      subscription_id: id
    }
    encode_payload = URI.encode_query(payload)
    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}

    with response <- HTTPoison.post(paddle_service, encode_payload, headers),
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
    {:ok, response} <- Poison.decode(body),
    %{"response" => response} <- response,
    subscription <- List.first(response) do
      subscription
    else
      _ ->
        nil
    end
  end

  @doc """
  Create a subscription from calling Paddle's api/2.0/subscription/users
  service. paddle_attrs must be one of the elements returned in the response
  array.

  See https://developer.paddle.com/api-reference/subscription-api/users/listusers

  ## Examples

      iex> create_subscription_from_paddle(owner_id, %{response from service})
      %{:ok, %Subscription{}}

      iex> create_subscription_from_paddle(owner_id, %{invalid})
      %{:error, %Changeset{}}

  """
  def create_subscription_from_paddle(owner_id, paddle_attrs \\ %{}) do
    %{"next_payment" => next_payment} = paddle_attrs
    %{"date" => date} = next_payment
    {:ok, next_bill_date_parsed} = NaiveDateTime.from_iso8601(date <> " 00:00:00")
    changeset = %{
      owner_id: owner_id,
      processor_id: paddle_attrs["subscription_id"] |> to_string,
      processor_plan: paddle_attrs["plan_id"] |> to_string,
      quantity: paddle_attrs["quantity"] || 1,
      ends_at: next_bill_date_parsed,
      status: paddle_attrs["state"],
      update_url: paddle_attrs["update_url"],
      cancel_url: paddle_attrs["cancel_url"]
    }

    create_paddle_subscription(changeset)
  end

  @doc """
  Gets a single Paddle subscription from the dabatase.
  If it can't be found, ask Paddle for it.
  If Paddle has a record, create a new entry in our database.

  ## Examples

      iex> get_paddle_subscription_or_recreate_from_paddle(%{processor_id: 42})
      %Subscription{}

      iex> get_paddle_subscription_or_recreate_from_paddle(%{processor_id: 24})
      nil

  """
  def get_paddle_subscription_or_recreate_from_paddle(attrs \\ %{}) do
    id = attrs.processor_id
    owner_id = attrs.owner_id
    filters = [processor_id: id, processor: "paddle"]

    case Repo.get_by(Subscription, filters) do
      %Subscription{} = subscription ->
        subscription
      nil ->
        with %{} = paddle_subscription <- get_subscription_from_paddle(id),
        {:ok, subscription} <- create_subscription_from_paddle(owner_id, paddle_subscription) do
          subscription
        else
          _ ->
            nil
        end
    end
  end

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs \\ %{}) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a Paddle subscription.

  ## Examples

      iex> create_paddle_subscription(%{subscription_id: 42, ...})
      {:ok, %Subscription{}}

      iex> create_paddle_subscription(%{subscription_id: 24, ...})
      {:error, %Ecto.Changeset{}}

  """
  def create_paddle_subscription(attrs \\ %{}) do
    attrs_with_paddle = attrs
    |> Map.put(:owner_type, "User")
    |> Map.put(:name, "default")
    |> Map.put(:processor, "paddle")
    create_subscription(attrs_with_paddle)
  end

  @doc """
  If a subscription exists in our database, it will update it.

  If the subscription doesn't exists in our database but does in
  the Paddle's platform. A new subscription will be created
  with the attrs.

  If the subscription doesn't exists at all, a new subscription
  will be created.

  ## Examples

      iex> update_or_create_paddle_subscription(%{field: new_value})
      {:ok, %Subscription{}}

      iex> update_or_create_paddle_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_or_create_paddle_subscription(attrs \\ %{}) do
    case get_paddle_subscription_or_recreate_from_paddle(attrs) do
      %Subscription{} = subscription ->
        update_subscription(subscription, attrs)
      nil ->
        create_paddle_subscription(attrs)
    end
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end

  alias TrackearAuth.Billings.Charge

  @doc """
  Returns the list of pay_charges.

  ## Examples

      iex> list_pay_charges()
      [%Charge{}, ...]

  """
  def list_pay_charges do
    Repo.all(Charge)
  end

  @doc """
  Gets a single charge.

  Raises `Ecto.NoResultsError` if the Charge does not exist.

  ## Examples

      iex> get_charge!(123)
      %Charge{}

      iex> get_charge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_charge!(id), do: Repo.get!(Charge, id)

  @doc """
  Creates a charge.

  ## Examples

      iex> create_charge(%{field: value})
      {:ok, %Charge{}}

      iex> create_charge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_charge(attrs \\ %{}) do
    %Charge{}
    |> Charge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a Paddle charge.

  ## Examples

      iex> create_charge(%{field: value})
      {:ok, %Charge{}}

      iex> create_charge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_paddle_charge(attrs \\ %{}) do
    attrs_with_paddle = attrs
    |> Map.put(:processor, "paddle")
    |> Map.put(:owner_type, "User")
    create_charge(attrs_with_paddle)
  end

  @doc """
  Updates a charge.

  ## Examples

      iex> update_charge(charge, %{field: new_value})
      {:ok, %Charge{}}

      iex> update_charge(charge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_charge(%Charge{} = charge, attrs) do
    charge
    |> Charge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a charge.

  ## Examples

      iex> delete_charge(charge)
      {:ok, %Charge{}}

      iex> delete_charge(charge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_charge(%Charge{} = charge) do
    Repo.delete(charge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking charge changes.

  ## Examples

      iex> change_charge(charge)
      %Ecto.Changeset{data: %Charge{}}

  """
  def change_charge(%Charge{} = charge, attrs \\ %{}) do
    Charge.changeset(charge, attrs)
  end
end
