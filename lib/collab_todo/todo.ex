defmodule CollabTodo.Todo do
  @moduledoc """
  The Todo context.
  """

  import Ecto.Query, warn: false
  alias CollabTodo.Repo

  alias CollabTodo.Todo.Room

  @spec get_room_by_phrase!(any) :: any
  def get_room_by_phrase!(phrase) do
    Repo.get_by!(Room, phrase: phrase)
  end

  def list_rooms do
    Repo.all(Room)
  end

  def get_room!(id), do: Repo.get!(Room, id)

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  alias CollabTodo.Todo.Task

  def get_tasks_by_room!(room_id) do
    Repo.all(from t in Task, where: t.room_id == ^room_id)
  end

  def list_tasks do
    Repo.all(Task)
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:task_created)
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
    |> broadcast(:task_updated)
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def room_topic(room_id), do: "room:#{room_id}"

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(CollabTodo.PubSub, topic)
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, struct}, event) do
    # Aqui to separando task_created e updated, mas por enquanto não teria pq, visto q é tudo
    # pra mesma room
    case event do
      :task_created ->
        Phoenix.PubSub.broadcast(CollabTodo.PubSub, room_topic(struct.room_id), {event, struct})

      :task_updated ->
        Phoenix.PubSub.broadcast(CollabTodo.PubSub, room_topic(struct.room_id), {event, struct})
    end

    {:ok, struct}
  end
end
