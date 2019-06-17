defmodule DonutsWeb.SessionController do
  use DonutsWeb, :controller
  @client_id Application.get_env(:donuts, :client_id)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  
  def sign_in(conn, _params) do
    redirect = @redirect_uri_auth |> URI.encode()
    link = "https://slack.com/oauth/authorize?scope=identity.basic&client_id=#{@client_id}&redirect_uri=#{redirect}"
    render(conn, "sign-in.html", link: link)
  end

  def auth(conn, params) do
    token_info = params |> Auth.get_code() |> Auth.get_token_info()

    if Map.get(token_info, "ok") == true do
      user_id = token_info |> Map.get("user") |> Map.get("id")
      if Accounts.get_by_slack_id(user_id) do
        Auth.create_session(token_info)
        conn
          |> put_session(:token, token_info["access_token"])
          |> redirect(to: Routes.page_path(conn, :logged_in))
      else
        conn
          |> put_flash(:info, "Sorry, it seems you are not in our user database.")
          |> redirect(to: Routes.page_path(conn, :index))
      end
    else
      conn
        |> put_flash(:info, "Sorry, it seems we have some kind of problem with logging in.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
