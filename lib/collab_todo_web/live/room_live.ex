defmodule CollabTodoWeb.RoomLive do
  use Phoenix.LiveView

  alias CollabTodo.Todo
  alias CollabTodoWeb.Presence
  alias CollabTodo.NicknameGenerator

  # TODO: Alert com os updates?
  # TODO: Live chat pra sala

  def mount(%{"phrase" => phrase}, _session, socket) do
    room = Todo.get_room_by_phrase!(phrase)
    tasks = Todo.get_tasks_by_room!(room.id)

    topic = Todo.room_topic(room.id)

    if connected?(socket) do
      Todo.subscribe(topic)
    end

    # Generate a random nickname
    nickname = NicknameGenerator.generate()

    # Get the name of users in the room and also their "nicknames"
    initial_count = Presence.list(topic) |> Enum.count()

    initial_names =
      Presence.list(topic)
      |> Enum.map(fn {_, %{metas: metas}} -> metas end)
      |> Enum.map(fn metas -> Enum.at(metas, 0)[:name] end)

    # Append self to list
    names = initial_names ++ [nickname]

    # Track changes to the topic
    Presence.track(
      self(),
      topic,
      socket.id,
      %{
        name: nickname
      }
    )

    {:ok,
     assign(socket,
       phrase: room.phrase,
       id: room.id,
       tasks: tasks,
       count: initial_count,
       nickname: nickname,
       names: names
     )}
  end

  def render(assigns) do
    ~H"""

    <.live_component module={NavComponent} id="nav" />

    <section class="m-auto px-4 max-w-7xl p-2 flex flex-col justify-center items-center">
      <h1 class="text-4xl font-bold text-center"> Welcome <span class="text-orange-600"> <%= @nickname %> </span> </h1>

      <%= if length(@tasks) == 0 do %>
        <h2 class="text-2xl font-bold text-center"> Anything in your mind? </h2>
      <% else %>
        <h2 class="text-2xl font-bold text-center"> Let's keep the progress going! </h2>
      <% end %>

      <%= if length(@names) > 1 do %>
        <h3 class="text-lg font-semibold text-center"> There are <%= @count %> users here: <span class="text-gray-700"> <%= concat_names(@names) %> </span> </h3>
      <% end %>



      <div class="my-2">
        <ul>
          <%= for task <- @tasks do %>
            <div class="flex flex-row gap-2 items-center align-middle px-3 py-2 rounded-lg">
              <input type="checkbox" name="task_status" checked={task.done} phx-click="task_status" phx-value-task-id={task.id}>
              <input type="text" class="border border-gray-300 text-gray-900 text-sm rounded-lg block w-full cursor-default w-96" value={task.text} disabled>
              <button
                  class="self-center cursor-pointer text-slate-600 w-5 h-5 mb-2"
                  phx-click="delete_task" phx-value-task-id={task.id}
                >
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
                  </svg>
              </button>
          </div>

          <% end %>
        </ul>
      </div>

      <form phx-submit="create_task" class="my-4">
        <label for="task" class="sr-only">Create Task</label>
        <div class="flex items-center p-2 rounded-lg bg-gray-100 w-96">
            <input id="task" name="task"
                class="block mx-4 my-2 p-2 w-full text-sm text-gray-900 bg-white rounded-lg border border-gray-300"
                placeholder="Your next task..."/>
            <button type="submit" value="task"
                class="inline-flex justify-center pr-2 text-orange-600 rounded-full cursor-pointer hover:text-orange-700 hover:stroke-2">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5" />
                </svg>
                <span class="sr-only">Send message</span>
            </button>
        </div>
      </form>
    </section>
    """
  end

  def concat_names(names) do
    Enum.join(names, ", ")
  end

  # Listen to events
  def handle_info({:task_created, task}, socket) do
    {:noreply, assign(socket, tasks: socket.assigns.tasks ++ [task])}
  end

  def handle_info({:task_updated, task}, socket) do
    tasks = socket.assigns.tasks
    updated_tasks = Enum.map(tasks, fn t -> if t.id == task.id, do: task, else: t end)
    {:noreply, assign(socket, tasks: updated_tasks)}
  end

  def handle_info({:task_deleted, task}, socket) do
    tasks = socket.assigns.tasks
    updated_tasks = Enum.reject(tasks, fn t -> t.id == task.id end)
    {:noreply, assign(socket, tasks: updated_tasks)}
  end

  # Listen for presence events
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    count = Presence.list(Todo.room_topic(socket.assigns.id)) |> Enum.count()

    names =
      Presence.list(Todo.room_topic(socket.assigns.id))
      |> Enum.map(fn {_, %{metas: metas}} -> metas end)
      |> Enum.map(fn metas -> Enum.at(metas, 0)[:name] end)

    {:noreply, assign(socket, count: count, names: names)}
  end

  def handle_event("create_task", %{"task" => text}, socket) do
    Todo.create_task(%{text: text, done: false, room_id: socket.assigns.id})
    {:noreply, socket}
  end

  def handle_event("task_status", params, socket) do
    task_id = params["task-id"]

    # If has "value" in params, then it's 'on', if no key, then its 'off'
    done = Map.has_key?(params, "value")

    task = Todo.get_task!(task_id)
    Todo.update_task(task, %{id: task_id, done: done})

    {:noreply, socket}
  end

  def handle_event("delete_task", params, socket) do
    task_id = params["task-id"]
    task = Todo.get_task!(task_id)
    Todo.delete_task(task)
    {:noreply, socket}
  end
end
