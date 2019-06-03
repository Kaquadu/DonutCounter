defmodule DonutsWeb.Services.UserCheck do
  alias Plug.Conn
  alias Donuts.Sessions
  alias Donuts.Accounts

  def logged_in?(conn) do
    session_token = conn |> Conn.get_session(:token)
    if session_token, do: Sessions.check_active(session_token)
  end

  def get_current_user_name(conn) do
      list = logged_in?(conn)
      if list != [] and list != nil do
        list
          |> List.first()
          |> Map.get(:user_id)
          |> Accounts.get_by_id()
          |> Map.get(:name)
      end
  end
end
