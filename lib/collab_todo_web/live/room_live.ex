defmodule CollabTodoWeb.RoomLive do
  use Phoenix.LiveView

  alias CollabTodo.Todo

  def mount(%{"phrase" => phrase}, _session, socket) do
    room = Todo.get_room_by_phrase!(phrase)
    tasks = Todo.get_tasks_by_room!(room.id)
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
              <input type="checkbox" name="done" checked={task.done} phx-click="done" phx-value-task-id={task.id}>

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

  # Precis odo room id
  def handle_event("create_task", %{"task" => text}, socket) do
    Todo.create_task(%{text: text, done: false, room_id: socket.assigns.id})

    tasks = Todo.get_tasks_by_room!(socket.assigns.id)

    IO.inspect(tasks, label: "tasks")

    {:noreply, assign(socket, tasks: tasks)}
  end

  def handle_event("done", %{"task-id" => task_id, "value" => val}, socket) do
    value_map = %{"on" => true, "off" => false}

    task = Todo.get_task!(task_id)
    Todo.update_task(task, %{id: task_id, done: value_map[val]})

    tasks = Todo.get_tasks_by_room!(socket.assigns.id)
    {:noreply, assign(socket, tasks: tasks)}
  end
end
