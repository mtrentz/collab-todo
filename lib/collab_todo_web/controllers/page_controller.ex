defmodule CollabTodoWeb.PageController do
  use CollabTodoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
