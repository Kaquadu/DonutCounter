defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def logged_in(conn, _params) do
    render conn, "logged_in.html"
  end
end
