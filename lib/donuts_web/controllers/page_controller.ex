defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller
  @client_id Application.get_env(:donuts, :client_id)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  @redirect_uri_loggedin Application.get_env(:donuts, :redirect_uri_loggedin)
  @client_secret Application.get_env(:donuts, :client_secret)
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)
  alias Donuts.Accounts
  alias Donuts.Helpers.Auth
  alias Donuts.Helpers.HTTPHelper

  plug DonutsWeb.Plugs.LoginStatus when action in [:logged_in, :add_donut]

  def index(conn, _params) do
    render conn, "index.html"
  end

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

  def logged_in(conn, _params) do
    user_stats = Donuts.Accounts.Statistics.get_statistics()
    render conn, "logged_in.html", stats: user_stats
  end

  def event_test(conn, params) do # only change in router when you have to verify your app in slack
    challange = Map.get(params, "challenge")
    conn |> send_resp(200, challange)
  end

  def event_handler(conn, %{"event" => event }) do
    Donuts.Donuts.handle_slack_event(event)
    conn |> send_resp(200, "")
  end

  def add_donut(conn, %{"donut" => %{"sender_name" => sender_name}}) do
    if Accounts.get_by_real_name(sender_name) do
      target_name = DonutsWeb.Services.UserCheck.get_current_user_name(conn)
      target_id = Accounts.get_by_real_name(target_name) |> Map.get(:id)

      %{}
        |> Map.put(:sender, sender_name)
        |> Map.put(:guilty, target_name)
        |> Map.put(:user_id, target_id)
        |> Map.put(:expiration_date, DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second))
        |> Map.put(:delivered, false)
        |> Donuts.Donuts.create_donut()
      conn |> redirect(to: Routes.page_path(conn, :logged_in))
    else
      conn
        |> put_flash(:info, "Incorrect name.")
        |> redirect(to: Routes.page_path(conn, :logged_in))
    end
  end
end
