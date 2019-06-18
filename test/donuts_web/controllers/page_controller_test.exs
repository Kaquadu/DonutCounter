defmodule DonutsWeb.PageControllerTest do
  use DonutsWeb.ConnCase
  alias DonutsWeb.Router.Helpers, as: Routes

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  # test "POST /event-occured", %{conn: conn} do
  #   conn = post(conn, Routes.page_path(conn, :event_handler, ))
  #   assert html_response(conn, 200)
  # end
end
