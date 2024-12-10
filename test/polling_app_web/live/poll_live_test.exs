defmodule PollingAppWeb.PollLiveTest do
  use PollingAppWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import PollingApp.PollingFixtures

  alias PollingApp.Polling.Poll
  alias PollingApp.Polling

  @create_attrs %{title: "some title", polling_options: %{"0": %{content: "Option 1"}}}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  setup [:register_and_log_in_user]

  defp create_poll(_) do
    poll = poll_fixture()
    %{poll: poll}
  end

  describe "Index" do
    setup [:create_poll]

    test "lists all polls", %{conn: conn, poll: poll} do
      {:ok, _index_live, html} = live(conn, ~p"/polls")

      assert html =~ "Listing Pols"
      assert html =~ poll.title
    end

    test "saves new poll", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/polls")

      assert index_live |> element("a", "New Poll") |> render_click() =~
               "New Poll"

      assert_patch(index_live, ~p"/polls/new")

      assert index_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> element("#some_id")
             |> render_click()

      assert index_live
             |> form("#poll-form", poll: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/polls")

      html = render(index_live)
      assert html =~ "Poll created successfully"
      assert html =~ "some title"
    end

    test "updates poll in listing", %{conn: conn, poll: _poll, user: user} do
      valid_attrs = %{
        title: "some title",
        user_id: user.id,
        polling_options: [%{content: "nothing"}, %{content: "nothing2"}]
      }

      assert {:ok, %Poll{} = poll} = Polling.create_poll(valid_attrs)

      {:ok, index_live, _html} = live(conn, ~p"/polls")

      assert index_live |> element("#polls-#{poll.id} a", "Edit") |> render_click() =~
               "Edit Poll"

      assert_patch(index_live, ~p"/polls/#{poll}/edit")

      assert index_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#poll-form", poll: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/polls")

      html = render(index_live)
      assert html =~ "Poll updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes poll in listing", %{conn: conn, poll: _poll, user: user} do
      valid_attrs = %{
        title: "some title",
        user_id: user.id,
        polling_options: [%{content: "nothing"}, %{content: "nothing2"}]
      }

      assert {:ok, %Poll{} = poll} = Polling.create_poll(valid_attrs)

      {:ok, index_live, _html} = live(conn, ~p"/polls")

      assert index_live |> element("#polls-#{poll.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#polls-#{poll.id}")
    end
  end

  describe "Show" do
    setup [:create_poll]

    test "Test Show Poll -> Vote -> View Result ", %{conn: conn, poll: poll} do
      {:ok, show_live, html} = live(conn, ~p"/polls/#{poll}")
      option = Enum.at(poll.polling_options, 0)
      elem_id = "#option-" <> Integer.to_string(option.id)

      result =
        show_live
        |> element(elem_id)
        |> render_click()

      # assert_push_event(show_live, "poll", %{new_vote: _vote})
      assert html =~ ""

      assert html =~ "Show Poll"
      assert result =~ poll.title
      assert result =~ option.content <> ": 1"
    end
  end
end
