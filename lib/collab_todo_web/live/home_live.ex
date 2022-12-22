defmodule CollabTodoWeb.HomeLive do
  use Phoenix.LiveView

  alias CollabTodo.Todo

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

    <.live_component module={NavComponent} id="nav" />

    <section class="m-auto px-4 max-w-7xl p-2 flex flex-col justify-center items-center">

      <div class="flex flex-col md:flex-row items-center justify-center align-middle gap-2">
        <h1 class="text-4xl font-bold text-center"> Welcome to</h1>
        <h1 class="text-4xl font-bold text-center text-orange-600"> Collab To-Do's </h1>
      </div>

      <h2 class="my-2 text-2xl font-bold text-center"> Create a random room for your tasks </h2>

      <button phx-click="create_room" class="flex w-64 my-4 justify-center rounded-md border border-transparent bg-orange-600 py-2 px-4 text-sm font-medium text-white hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2">
          Start a new To-Do
      </button>

      <h2 class="my-2 text-2xl font-bold text-center"> Or join an existing one </h2>

      <form phx-submit="join_room" class="flex flex-col align-middle justify-center">
        <input type="text" id="room" name="room" class="border border-gray-300 text-gray-900 text-sm rounded-lg block w-full w-96" placeholder="Room phrase">
        <button type="submit" value="room" phx-click="create_room" class="self-center flex w-64 my-4 justify-center rounded-md border border-transparent bg-orange-600 py-2 px-4 text-sm font-medium text-white hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2">
          Join
       </button>
      </form>
    </section>
    """
  end

  # Create random room and redirect to it
  def handle_event("create_room", _params, socket) do
    phrase = MnemonicSlugs.generate_slug(5)
    # Usar create_room oualgo assim
    # Repo.insert!(%Room{phrase: phrase})
    Todo.create_room(%{phrase: phrase})
    {:noreply, push_redirect(socket, to: "/room?phrase=#{phrase}")}
  end

  # Join existing room
  def handle_event("join_room", %{"room" => phrase}, socket) do
    {:noreply, push_redirect(socket, to: "/room?phrase=#{phrase}")}
  end
end
