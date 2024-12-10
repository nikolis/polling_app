defmodule PollingAppWeb.PollLive.FormComponent do
  use PollingAppWeb, :live_component

  alias PollingApp.Polling

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>
      <.simple_form
        :let={form}
        for={@changeset}
        id="poll-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={form[:title]} type="text" label="Title" />
        <.input field={form[:user_id]} type="hidden" />

        <div class="w-full min-h-20 border-solid shadow-lg p-8 relative m-2 ">
          <h3 class="m-auto w-fit text-lg">Polling options</h3>
          <button
            id="some_id"
            type="button"
            class="bg-grey  rounded-full  absolute bottom-2 right-2 border-2"
            phx-click="add-option"
            phx-target={@myself}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="2"
              stroke="grey"
              class="size-8 p-1"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
          </button>
          <.inputs_for :let={g} field={form[:polling_options]}>
            <div
              class={"grid grid-cols-6" <> if Map.get(g.source.changes, :delete)  do " hidden"  else ""  end}
              ,
              id={"recipe_ingredients" <> to_string(g.index)}
            >
              <.input field={g[:delete]} type="hidden" index={g.index} />

              <div class="col-span-5">
                <.input required field={g[:content]} type="text" />
              </div>

              <div class="form-group w-full">
                <%= if is_nil Map.get(g.source.changes, :temp_id, nil) do %>
                  <div class="m-auto h-full w-full color-transparent">
                    <.input field={g[:delete]} type="checkbox_covered" index={Map.get(g, :index, 1)} />
                    <.icon name="hero-delete" class="h-12 w-12" />
                  </div>
                <% else %>
                  <.input field={g[:temp_id]} type="hidden" index={g.index} />

                  <svg
                    phx-click="remove-option"
                    phx-target={@myself}
                    style="width:25px; height: 100%; margin: auto;"
                    phx-value-temp_id={g.data.temp_id || Map.get(g.source.changes, :temp_id, nil)}
                    id={"button_remove_option"<> Integer.to_string(g.index)}
                    width="2rem"
                    height="60px"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                    style=""
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    class="size-6 w-fit"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
                    />
                  </svg>
                <% end %>
              </div>
            </div>
          </.inputs_for>
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Poll</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  @impl true
  def update(%{poll: poll} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> init(poll)}
  end

  defp add_polling_option_to_changeset(changeset) do
    existing = Ecto.Changeset.get_assoc(changeset, :polling_options)

    Ecto.Changeset.put_assoc(
      changeset,
      :polling_options,
      existing ++ [%{temp_id: get_temp_id()}]
    )
  end

  defp init(socket, base, attrs \\ %{}) do
    changeset =
      Polling.change_poll(base, attrs)

    assign(socket,
      base: base,
      changeset: changeset,
      # Reset form for LV
      id: "form-#{System.unique_integer()}"
    )
  end

  @impl true
  def handle_event("add-option", _params, socket) do
    changeset = add_polling_option_to_changeset(socket.assigns.changeset)
    socket = assign(socket, :changeset, changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove-option", %{"temp_id" => remove_id}, socket) do
    {_progress, options} = remove_from_change(socket, remove_id)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:polling_options, options)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    changeset =
      Polling.change_poll(socket.assigns.poll, poll_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"poll" => poll_params}, socket) do
    save_poll(socket, socket.assigns.action, poll_params)
  end

  defp save_poll(socket, :edit, poll_params) do
    case Polling.update_poll(socket.assigns.poll, poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})

        {:noreply,
         socket
         |> put_flash(:info, "Poll updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_poll(socket, :new, poll_params) do
    case Polling.create_poll(poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})

        {:noreply,
         socket
         |> put_flash(:info, "Poll created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  ########################################################################################## Helper Function  ##########################################
  defp remove_from_change(socket, remove_id) do
    case Map.get(socket.assigns.changeset.changes, :polling_options, nil) do
      nil ->
        {:repeat, []}

      option_changes ->
        original_length = length(option_changes)

        result_changes =
          option_changes
          |> Enum.reject(fn %{changes: option} = _rest ->
            Map.get(option, :temp_id, nil) == remove_id
          end)

        case length(result_changes) == original_length do
          true ->
            {:repeat, result_changes}

          false ->
            {:ok, result_changes}
        end
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
