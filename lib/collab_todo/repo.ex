defmodule CollabTodo.Repo do
  use Ecto.Repo,
    otp_app: :collab_todo,
    adapter: Ecto.Adapters.Postgres
end
