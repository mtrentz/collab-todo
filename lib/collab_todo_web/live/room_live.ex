defmodule CollabTodoWeb.RoomLive do
  use Phoenix.LiveView

  alias CollabTodo.Todo

  def mount(%{"phrase" => phrase}, _session, socket) do
    room = Todo.get_room_by_phrase!(phrase)
    tasks = Todo.get_tasks_by_room!(room.id)

    if connected?(socket) do
      Todo.subscribe(room.id)
    end

    {:ok, assign(socket, phrase: room.phrase, id: room.id, tasks: tasks)}
  end

  def render(assigns) do
    ~H"""
    <section class="container">
      <h1> Phrase: <%= @phrase %> </h1>
      <h2> ID: <%= @id %> </h2>

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

  # Precis odo room id
  def handle_event("create_task", %{"task" => text}, socket) do
    Todo.create_task(%{text: text, done: false, room_id: socket.assigns.id})
    {:noreply, socket}
  end

  def handle_event("task_status", params, socket) do
    IO.inspect(params, label: "params")

    task_id = params["task-id"]

    # If has "value" in params, then it's 'on', if no key, then its 'off'
    done = Map.has_key?(params, "value")

    task = Todo.get_task!(task_id)
    Todo.update_task(task, %{id: task_id, done: done})

    {:noreply, socket}
  end
end
