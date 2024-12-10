defmodule PollingApp.Polling do
  @moduledoc """
  The Polling context.
  """

  import Ecto.Query, warn: false
  alias PollingApp.Repo

  alias PollingApp.Polling.Poll
  alias PollingApp.Polling.Vote

  @doc """
  Returns the list of votes for particular poll.

  ## Examples

      iex> list_votes(25)
      [%Poll{}, ...]

  """
  def list_votes(poll_id) do
    Repo.all(from vo in Vote, where: vo.poll_id == ^poll_id)
    |> Repo.preload([:polling_option, :user])
  end

  def subscribe_to_poll(%{poll_id: poll_id}) do
    Phoenix.PubSub.subscribe(PollingApp.PubSub, "poll:" <> to_string(poll_id))
  end

  defp broadcast_change({:ok, vote}) do
    Phoenix.PubSub.broadcast(PollingApp.PubSub, "poll:" <> to_string(vote.poll_id), %{
      new_vote: vote
    })

    {:ok, vote}
  end

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(attrs \\ %{}) do
    result =
      %Vote{}
      |> Vote.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, vote} ->
        {:ok,
         vote
         |> Repo.preload([:polling_option])}
        |> broadcast_change()

      _ ->
        result
    end
  end

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    Repo.all(Poll)
    |> Repo.preload(:polling_options)
  end

  @doc """
  Gets a single poll.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll!(123)
      %Poll{}

      iex> get_poll!(456)
      ** (Ecto.NoResultsError)

  """
  def get_poll!(id) do
    Repo.get!(Poll, id)
    |> Repo.preload(:polling_options)
  end

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(%{field: value})
      {:ok, %Poll{}}

      iex> create_poll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs \\ %{}) do
    result =
      %Poll{}
      |> Poll.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, poll} ->
        {:ok, Repo.preload(poll, :polling_options)}

      with_errors ->
        with_errors
    end
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})
      {:ok, %Poll{}}

      iex> update_poll(poll, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll(poll)
      %Ecto.Changeset{data: %Poll{}}

  """
  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end
end
