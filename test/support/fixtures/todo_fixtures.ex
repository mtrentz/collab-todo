defmodule CollabTodo.TodoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CollabTodo.Todo` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        phrase: "some phrase"
      })
      |> CollabTodo.Todo.create_room()

    room
  end

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        done: true,
        text: "some text"
      })
      |> CollabTodo.Todo.create_task()

    task
  end
end
