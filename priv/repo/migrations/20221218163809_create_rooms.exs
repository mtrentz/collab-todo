defmodule CollabTodo.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :phrase, :string

      timestamps()
    end
  end
end
