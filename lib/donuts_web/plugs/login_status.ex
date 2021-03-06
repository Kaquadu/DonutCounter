defmodule DonutsWeb.Plugs.LoginStatus do
  use DonutsWeb, :controller
  import Plug.Conn
  alias Donuts.Repo
  alias Donuts.Sessions
  alias DonutsWeb.Router.Helpers, as: Routes

  def call(%Plug.Conn{} = conn, _opts) do
    active_token =
      conn
      |> get_session(:token)
      |> Sessions.check_active()

    if active_token != [] do
      conn
    else
      conn
      |> put_flash(:info, "Your session has expired.")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
