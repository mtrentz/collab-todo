defmodule CollabTodoWeb.HomeLive do
  use Phoenix.LiveView

  alias CollabTodo.Todo.Room
  alias CollabTodo.Repo

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="container">
      <button phx-click="create_room">Create new To-Do</button>

      <form phx-submit="join_room">
        <label for="room"> Join existing To-Do </label>
        <input type="text" id="room" name="room">
        <button type="submit" value="room">Join</button>
      </form>
    </section>
    """
  end

  # Create random room and redirect to it
  def handle_event("create_room", _params, socket) do
    phrase = MnemonicSlugs.generate_slug(5)
    # Usar create_room oualgo assim
    Repo.insert!(%Room{phrase: phrase})
    {:noreply, push_redirect(socket, to: "/room?phrase=#{phrase}")}
  end

  # Join existing room
  def handle_event("join_room", %{"room" => phrase}, socket) do
    {:noreply, push_redirect(socket, to: "/room?phrase=#{phrase}")}
  end
end
