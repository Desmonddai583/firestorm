defmodule FirestormWeb.Api.V1.PreviewControllerTest do
  use FirestormWeb.ConnCase
  alias FirestormWeb.Markdown

  # We'll verify that we can post a Post to the preview endpoint and receive
  # back a data structure containing the rendered markdown.
  test "POST /", %{conn: conn} do
    post = %{
      "body" => "this is **neat**",
    }
    conn = post conn, "/api/v1/preview", post: post
    response = json_response(conn, 201)["data"]
    assert response["html"] == Markdown.render(post["body"])
  end
end