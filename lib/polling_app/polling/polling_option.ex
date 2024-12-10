defmodule PollingApp.Polling.PollingOption do
  @moduledoc """
  This is Module represents the options available wihin a context of a poll  
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "polling_options" do
    field :content, :string

    field :delete, :boolean, virtual: true
    field :temp_id, :string, virtual: true

    belongs_to :poll, PollingApp.Polling.Poll, on_replace: :delete_if_exists

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(polling_option, attrs) do
    polling_option
    |> cast(attrs, [:content, :delete, :temp_id])
    |> validate_required([:content])
    |> foreign_key_constraint(:poll_id)
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
