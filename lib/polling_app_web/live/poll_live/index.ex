defmodule PollingAppWeb.PollLive.Index do
  use PollingAppWeb, :live_view

  alias PollingApp.Polling
  alias PollingApp.Polling.Poll

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :polls, Polling.list_polls())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Poll")
    |> assign(:poll, Polling.get_poll!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Poll")
    |> assign(:poll, %Poll{user_id: socket.assigns.current_user.id, polling_options: []})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pols")
    |> assign(:poll, nil)
  end

  @impl true
  def handle_info({PollingAppWeb.PollLive.FormComponent, {:saved, poll}}, socket) do
    {:noreply, stream_insert(socket, :polls, poll)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    poll = Polling.get_poll!(id)
    {:ok, _} = Polling.delete_poll(poll)

    {:noreply, stream_delete(socket, :polls, poll)}
  end
end
