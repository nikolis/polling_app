defmodule PollingApp.Repo.Migrations.CreatePols do
  use Ecto.Migration

  def change do
    create table(:polls) do
      add :title, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:polls, [:user_id])
  end
end
