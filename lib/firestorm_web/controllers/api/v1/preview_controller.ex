defmodule FirestormWeb.Api.V1.PreviewController do
  use FirestormWeb, :controller
  alias FirestormWeb.Markdown

  def create(conn, %{"post" => post_params}) do
    conn
    |> put_status(201)
    |> render("show.json", html: Markdown.render(post_params["body"]))
  end
end