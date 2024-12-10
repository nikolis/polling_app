defmodule PollingApp.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username])
    |> validate_username(opts)
  end

  defp validate_username(changeset, opts) do
    changeset
    |> validate_required([:username])
    |> validate_length(:username, max: 160)
    |> validate_unique_username(opts)
  end

  defp validate_unique_username(changeset, _opts) do
    changeset
    |> unsafe_validate_unique(:username, PollingApp.Repo)
    |> unique_constraint(:username)
  end
end
