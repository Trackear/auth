defmodule TrackearAuth.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:users) do
      add :email, :string
      add :password, :string
      add :first_name, :string
      add :last_name, :string

      timestamps()
    end

  end
end
