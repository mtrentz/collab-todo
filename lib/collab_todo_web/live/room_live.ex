defmodule CollabTodoWeb.RoomLive do
  use Phoenix.LiveView

  alias CollabTodo.Todo
  alias CollabTodoWeb.Presence
  alias CollabTodo.NicknameGenerator

  def mount(%{"phrase" => phrase}, _session, socket) do
    room = Todo.get_room_by_phrase!(phrase)
    tasks = Todo.get_tasks_by_room!(room.id)

    topic = Todo.room_topic(room.id)

    if connected?(socket) do
      Todo.subscribe(topic)
    end

    # Short random name
    random_name = NicknameGenerator.generate()

    initial_count = Presence.list(topic) |> Enum.count()

    initial_names =
      Presence.list(topic)
      |> Enum.map(fn {_, %{metas: metas}} -> metas end)
      |> Enum.map(fn metas -> Enum.at(metas, 0)[:name] end)

    # Append self to list
    names = initial_names ++ [random_name]

    # Track changes to the topic
    Presence.track(
      self(),
      topic,
      socket.id,
      %{
        name: random_name
      }
    )

    {:ok,
     assign(socket,
       phrase: room.phrase,
       id: room.id,
       tasks: tasks,
       count: initial_count,
       names: names
     )}
  end

  def render(assigns) do
    ~H"""
    <section class="container">
      <h1> Phrase: <%= @phrase %> </h1>
      <h2> ID: <%= @id %> </h2>
      <h3> Amount of users here <span><%= @count %></span></h3>
      <div>
        <h1>Names</h1>
        <ul>
          <%= for name <- @names do %>
            <li>
              <%= name %>
            </li>
          <% end %>
        </ul>
      </div>

      <div>
        <h1>Tasks</h1>
        <ul>
          <%= for task <- @tasks do %>
            <!-- Input checkbox for 'done' -->
            <div class="row">
              <input type="checkbox" name="task_status" checked={task.done} phx-click="task_status" phx-value-task-id={task.id}>

              <li>
                <%= task.text %>
              </li>
            </div>
          <% end %>
        </ul>
      </div>

      <form phx-submit="create_task">
        <label for="task"> Create task </label>
        <input type="text" id="task" name="task">
        <button type="submit" value="task">Create</button>
      </form>
    </section>
    """
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

  # Listen for presence events
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    count = Presence.list(Todo.room_topic(socket.assigns.id)) |> Enum.count()

    names =
      Presence.list(Todo.room_topic(socket.assigns.id))
      |> Enum.map(fn {_, %{metas: metas}} -> metas end)
      |> Enum.map(fn metas -> Enum.at(metas, 0)[:name] end)

    {:noreply, assign(socket, count: count, names: names)}
  end

  # Precis odo room id
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
end
