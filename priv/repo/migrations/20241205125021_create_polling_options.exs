defmodule PollingApp.Repo.Migrations.CreatePollingOptions do
  use Ecto.Migration

  def change do
    create table(:polling_options) do
      add :content, :string
      # polling_options only make sense to exist within the context of a poll 
      add :poll_id, references(:polls, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:polling_options, [:poll_id])
  end
end
