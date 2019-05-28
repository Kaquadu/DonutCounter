defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller
  @client_id Application.get_env(:donuts, :client_id)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  @redirect_uri_loggedin Application.get_env(:donuts, :redirect_uri_loggedin)
  @client_secret Application.get_env(:donuts, :client_secret)
  alias DonutsWeb.Router.Helpers, as: Routes
  alias Donuts.Accounts
  alias Donuts.Helpers.Auth
  alias Donuts.Helpers.HTTPHelper

  plug DonutsWeb.Plugs.LoginStatus when action in [:logged_in]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def sign_in(conn, _params) do
    link = "https://slack.com/oauth/authorize?scope=identity.basic&client_id=#{@client_id}&redirect_uri=#{@redirect_uri_auth}"
    render conn, "sign-in.html", link: link
  end

  def auth(conn, params) do
    token_info = params |> Auth.get_code() |> Auth.get_token_info()

    user_id = token_info |> Map.get("user") |> Map.get("id")
    if Accounts.get_by_slack_id(user_id) do
      Auth.create_session(token_info)
      conn
        |> put_session(:token, token_info["access_token"])
        |> redirect(to: Routes.page_path(conn, :logged_in))
    else
      conn
        |> put_flash(:info, "Sorry, it seems you are not in our user database yet.")
        |> redirect(to: Routes.page_path(conn, :idex))
    end
  end

  def logged_in(conn, _params) do
    render conn, "logged_in.html"
  end

  def event_hander(conn, %{"event" => event }) do
    conn |> send_resp(200, "")
  end
end
