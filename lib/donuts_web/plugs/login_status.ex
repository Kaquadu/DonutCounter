defmodule DonutsWeb.Plugs.LoginStatus do
  use DonutsWeb, :controller
  import Plug.Conn
  alias Donuts.Repo
  alias Donuts.Sessions
  alias DonutsWeb.Router.Helpers, as: Routes

  def call(%Plug.Conn{} = conn, _opts) do
    active_token =
      conn
      |> get_session(:token) |> IO.inspect()
      |> Sessions.check_token_activity() |> IO.inspect()

    manage_session(conn, active_token)
  end

  def manage_session(conn, []) do
    conn
    |> put_flash(:info, "You have to log in.")
    |> redirect(to: Routes.session_path(conn, :sign_in))
  end

  def manage_session(conn, active_token) do
    conn
  end
end
