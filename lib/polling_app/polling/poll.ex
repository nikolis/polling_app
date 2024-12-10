defmodule PollingApp.Polling.Poll do
  @moduledoc """
  The fundemental processing unit of the application. 
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "polls" do
    field :title, :string
    field :user_id, :id

    has_many :polling_options, PollingApp.Polling.PollingOption, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
    |> cast_assoc(:polling_options, required: true)
  end
end
