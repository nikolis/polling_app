defmodule PollingApp.Polling.Vote do
  @moduledoc """
  This is Module represents the Vote of a user on a particular Poll 
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    belongs_to :user, PollingApp.Accounts.User
    belongs_to :poll, PollingApp.Polling.Poll
    belongs_to :polling_option, PollingApp.Polling.PollingOption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:user_id, :polling_option_id, :poll_id])
    |> validate_required([:user_id, :polling_option_id, :poll_id])
    |> unique_constraint([:user_id, :poll_id])
  end
end
