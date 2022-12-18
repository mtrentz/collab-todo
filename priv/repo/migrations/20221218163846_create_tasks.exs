defmodule CollabTodo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :done, :boolean, default: false, null: false
      add :room_id, references(:rooms, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:tasks, [:room_id])
  end
end
