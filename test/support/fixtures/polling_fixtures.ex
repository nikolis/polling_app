defmodule PollingApp.PollingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PollingApp.Polling` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    user = PollingApp.AccountsFixtures.user_fixture()

    {:ok, poll} =
      attrs
      |> Enum.into(%{
        title: "some title",
        user_id: user.id,
        polling_options: [%{content: "option 1"}]
      })
      |> PollingApp.Polling.create_poll()

    poll
    |> inspect(label: "THe actuiao aspdoll")

    poll
  end
end
