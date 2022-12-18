defmodule CollabTodo.TodoTest do
  use CollabTodo.DataCase

  alias CollabTodo.Todo

  describe "rooms" do
    alias CollabTodo.Todo.Room

    import CollabTodo.TodoFixtures

    @invalid_attrs %{phrase: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Todo.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Todo.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{phrase: "some phrase"}

      assert {:ok, %Room{} = room} = Todo.create_room(valid_attrs)
      assert room.phrase == "some phrase"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todo.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{phrase: "some updated phrase"}

      assert {:ok, %Room{} = room} = Todo.update_room(room, update_attrs)
      assert room.phrase == "some updated phrase"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Todo.update_room(room, @invalid_attrs)
      assert room == Todo.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Todo.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Todo.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Todo.change_room(room)
    end
  end

  describe "tasks" do
    alias CollabTodo.Todo.Task

    import CollabTodo.TodoFixtures

    @invalid_attrs %{done: nil, text: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Todo.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Todo.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{done: true, text: "some text"}

      assert {:ok, %Task{} = task} = Todo.create_task(valid_attrs)
      assert task.done == true
      assert task.text == "some text"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todo.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{done: false, text: "some updated text"}

      assert {:ok, %Task{} = task} = Todo.update_task(task, update_attrs)
      assert task.done == false
      assert task.text == "some updated text"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Todo.update_task(task, @invalid_attrs)
      assert task == Todo.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Todo.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Todo.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Todo.change_task(task)
    end
  end
end
