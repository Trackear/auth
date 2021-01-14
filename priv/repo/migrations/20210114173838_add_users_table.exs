defmodule TrackearAuth.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def up do
    create_if_not_exists table("users") do
      add :email, :string
      add :encrypted_password, :string
      add :first_name, :string
      add :last_name, :string
    end
  end

  def down do
    drop_if_exists table("users")
  end
end
