defmodule PollingAppWeb.PollLive.Show do
  use PollingAppWeb, :live_view

  alias PollingApp.Polling

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    poll_votes = Polling.list_votes(id)
    Polling.subscribe_to_poll(%{poll_id: id})

    current_user_voted? =
      socket.assigns.current_user.id in Enum.map(poll_votes, fn x -> x.user_id end)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_user_voted?, current_user_voted?)
     |> assign(:votes, poll_votes)
     |> assign(:poll, Polling.get_poll!(id))}
  end

  @impl true
  def handle_info(%{new_vote: vote}, socket) do

    #Filter for the case that the user voting recieves the notification for his one vote
    poll_votes = Enum.filter(socket.assigns.votes, fn x -> x.user_id != vote.user_id end) ++ [vote]  
    
    current_user_voted? =
      socket.assigns.current_user.id in Enum.map(poll_votes, fn x -> x.user_id end)

    socket =
      socket
      |> assign(:current_user_voted?, current_user_voted?)
      |> assign(:votes, poll_votes)

    {:noreply, socket}
  end

  @impl true
  def handle_event("vote", %{"poll-id" => poll_id, "option-id" => option_id}, socket) do
    vote =
      Polling.create_vote(%{
        poll_id: poll_id,
        polling_option_id: option_id,
        user_id: socket.assigns.current_user.id
      })

    poll_votes = Polling.list_votes(poll_id)

    current_user_voted? =
      socket.assigns.current_user.id in Enum.map(poll_votes, fn x -> x.user_id end)

    socket =
      case vote do
        {:ok, _vote} ->
          socket

        {:error, _changeset} ->
          put_flash(socket, :info, "You have already voted")
      end

    {:noreply,
     socket
     |> assign(:votes, poll_votes)
     |> assign(:current_user_voted?, current_user_voted?)}
  end


  # Transform the votes list into a map having options.content as keys and their freiquencies as values
  # from presentation purpuses
  defp transform_votes(poll_votes) do
    poll_votes 
    |> Enum.group_by(fn x -> x.polling_option.content end, fn x -> x.user_id end)
    |> Map.to_list()
    |> Enum.map(fn {x, y} -> {x, length(y)} end)
  end

  defp page_title(:show), do: "Show Poll"
  defp page_title(:edit), do: "Edit Poll"
end
