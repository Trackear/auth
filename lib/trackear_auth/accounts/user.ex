defmodule TrackearAuth.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :first_name, :string
    field :last_name, :string
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name])
    |> validate_required([:email, :password, :first_name, :last_name])
    |> validate_format(:email, ~r/@/)
    |> add_encrypted_password
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
