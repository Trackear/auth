defmodule TrackearAuth.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :token, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> set_token
  end

  defp set_token(changeset) do
    token_length = 128

    token =
      :crypto.strong_rand_bytes(token_length)
      |> Base.encode64()
      |> binary_part(0, token_length)

    changeset
    |> put_change(:token, token)
  end
end
