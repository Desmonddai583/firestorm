defmodule FirestormWeb.PageControllerTest do
  use FirestormWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "New Category"
  end
end
