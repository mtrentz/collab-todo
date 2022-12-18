defmodule CollabTodo.Todo.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :done, :boolean, default: false
    field :text, :string
    field :room_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:text, :done, :room_id])
    |> validate_required([:text, :done, :room_id])
  end
end
