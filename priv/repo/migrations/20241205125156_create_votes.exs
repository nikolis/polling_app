defmodule PollingApp.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :poll_id, references(:polls, on_delete: :delete_all)
      add :polling_option_id, references(:polling_options, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:votes, [:user_id])
    create index(:votes, [:poll_id])
    create index(:votes, [:polling_option_id])
    # Ensure db layer uniqueness per requirement
    # User can only vote once in a single poll
    create unique_index(:votes, [:user_id, :poll_id], name: :user_id_poll_id)
  end
end
