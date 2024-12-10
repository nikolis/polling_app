defmodule PollingApp.PollingTest do
  use PollingApp.DataCase

  alias PollingApp.Polling

  describe "votes" do 
    alias PollingApp.Polling.Poll
    alias PollingApp.Polling.Vote

    test "Vote, User Should be able to vote once at any given poll "  do
      user = PollingApp.AccountsFixtures.user_fixture()
      valid_attrs = %{
        title: "some title",
        user_id: user.id,
        polling_options: [%{content: "nothing"}, %{content: "nothing2"}]
      }
      assert {:ok, %Poll{} = poll} = Polling.create_poll(valid_attrs)

      option = Enum.at(poll.polling_options, 0)
      assert {:ok, %Vote{} = _vote} = Polling.create_vote(%{user_id: user.id, poll_id: poll.id, polling_option_id: option.id})
    end

    test "Vote, User Should not be able to vote twice at any given poll "  do
      user = PollingApp.AccountsFixtures.user_fixture()
      valid_attrs = %{
        title: "some title",
        user_id: user.id,
        polling_options: [%{content: "nothing"}, %{content: "nothing2"}]
      }
      assert {:ok, %Poll{} = poll} = Polling.create_poll(valid_attrs)

      option = Enum.at(poll.polling_options, 0)

      assert {:ok, %Vote{} = _vote} = Polling.create_vote(%{user_id: user.id, poll_id: poll.id, polling_option_id: option.id})
      assert {:error, _} = Polling.create_vote(%{user_id: user.id, poll_id: poll.id, polling_option_id: option.id})
    end

  end

  describe "polls" do
    alias PollingApp.Polling.Poll

    import PollingApp.PollingFixtures

    @invalid_attrs %{title: nil}

    test "list_polls/0 returns all polls" do
      poll = poll_fixture()
      assert Polling.list_polls() == [poll]
    end

    test "get_poll!/1 returns the poll with given id" do
      poll = poll_fixture()
      assert Polling.get_poll!(poll.id) == poll
    end

    test "create_poll/1 with valid data creates a poll" do
      user = PollingApp.AccountsFixtures.user_fixture()

      valid_attrs = %{
        title: "some title",
        user_id: user.id,
        polling_options: [%{content: "nothing"}, %{content: "nothing2"}]
      }

      assert {:ok, %Poll{} = poll} = Polling.create_poll(valid_attrs)
      assert length(poll.polling_options) == 2
      assert poll.title == "some title"
    end

    test "create_poll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polling.create_poll(@invalid_attrs)
    end

    test "update_poll/2 with valid data updates the poll" do
      poll = poll_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Poll{} = poll} = Polling.update_poll(poll, update_attrs)
      assert poll.title == "some updated title"
    end

    test "update_poll/2 with invalid data returns error changeset" do
      poll = poll_fixture()
      assert {:error, %Ecto.Changeset{}} = Polling.update_poll(poll, @invalid_attrs)
      assert poll == Polling.get_poll!(poll.id)
    end

    test "delete_poll/1 deletes the poll" do
      poll = poll_fixture()
      assert {:ok, %Poll{}} = Polling.delete_poll(poll)
      assert_raise Ecto.NoResultsError, fn -> Polling.get_poll!(poll.id) end
    end

    test "change_poll/1 returns a poll changeset" do
      poll = poll_fixture()
      assert %Ecto.Changeset{} = Polling.change_poll(poll)
    end
  end
end
