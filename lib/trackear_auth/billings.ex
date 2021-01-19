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
  Gets a subscription from Paddle.

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

    case HTTPoison.post(paddle_service, payload) do
      {:ok, response} ->
        response.body
      _ ->
        nil
    end
  end

  @doc """
  Gets a single Paddle subscription from the dabatase.
  If it can't be found, ask Paddle for it.
  If Paddle has a record, create a new entry in our database.

  ## Examples

      iex> get_paddle_subscription_or_recreate_from_paddle(%{subscription_id: 42})
      %Subscription{}

      iex> get_paddle_subscription_or_recreate_from_paddle(%{subscription_id: 24})
      nil

  """
  def get_paddle_subscription_or_recreate_from_paddle(attrs \\ %{}) do
    id = attrs.subscription_id
    filters = [processor_id: id, processor: "paddle"]
    case Repo.get_by(Subscription, filters) do
      %Subscription{} = subscription ->
        subscription
      nil ->
        with %{} = paddle_subscription <- get_subscription_from_paddle(id),
        {:ok, subscription} <- create_paddle_subscription(paddle_subscription) do
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
end
