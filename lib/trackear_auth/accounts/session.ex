defmodule TrackearAuth.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :token, :string
    field :user_id, :id
    field :created_at, :naive_datetime
    field :updated_at, :naive_datetime

    # timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> set_ruby_timestamp()
    |> set_token()
  end

  defp set_ruby_timestamp(changeset) do
    today = NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)

    changeset
    |> put_change(:created_at, today)
    |> put_change(:updated_at, today)
  end

  defp set_token(changeset) do
    token_length = 128

    token =
      :crypto.strong_rand_bytes(token_length)
      |> Base.encode64()
      |> String.replace("/", "-")

    changeset
    |> put_change(:token, token)
  end
end
