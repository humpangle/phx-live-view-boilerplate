defmodule MeAppWeb.PageControllerTest do
  use MeAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome - MeApp"
  end
end
