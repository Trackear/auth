defmodule TrackearAuth.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def up do
    create_if_not_exists table("sessions") do
      add :token, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:sessions, [:user_id])
  end

  def down do
    drop_if_exists table("sessions")
  end
end
