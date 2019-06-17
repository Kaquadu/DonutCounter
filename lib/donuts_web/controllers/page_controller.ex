defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller
  @redirect_uri_loggedin Application.get_env(:donuts, :redirect_uri_loggedin)
  @client_secret Application.get_env(:donuts, :client_secret)
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)
  alias Donuts.Sessions.Session
  alias Donuts.Accounts
  alias Donuts.Helpers.Auth
  alias Donuts.Helpers.HTTPHelper

  plug DonutsWeb.Plugs.LoginStatus when action in [:logged_in, :add_donut]

  def index(conn, _params) do
    render conn, "index.html"
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
      target_name = Session.get_current_user_name(conn)
      target_id = Accounts.get_by_real_name(target_name) |> Map.get(:id)

      %{:sender => sender_name,
        :guilty => target_name,
        :user_id => target_id,
        :expiration_date => DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
        :delivered => false}
      |> Donuts.Donuts.create_donut()

      conn |> redirect(to: Routes.page_path(conn, :logged_in))
    else
      conn
        |> put_flash(:info, "Incorrect name.")
        |> redirect(to: Routes.page_path(conn, :logged_in))
    end
  end
end
