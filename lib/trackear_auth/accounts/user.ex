defmodule TrackearAuth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :first_name, :string
    field :last_name, :string
    field :picture, :string
    field :created_at, :naive_datetime
    field :updated_at, :naive_datetime
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name, :picture])
    |> validate_required([:email, :password, :first_name])
    |> validate_format(:email, ~r/@/)
    |> set_ruby_timestamps()
    |> add_encrypted_password()
  end

  @doc false
  defp set_ruby_timestamps(changeset) do
    today = NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)

    changeset
    |> put_change(:created_at, today)
    |> put_change(:updated_at, today)
  end

  @doc false
  defp add_encrypted_password(changeset) do
    if Map.has_key?(changeset.changes, :password) do
      password = changeset.changes.password
      encrypted_password = Bcrypt.hash_pwd_salt(password)

      changeset
      |> put_change(:encrypted_password, encrypted_password)
    else
      changeset
    end
  end
end
