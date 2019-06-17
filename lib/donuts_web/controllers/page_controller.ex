defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller
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
    Donuts.Donuts.add_new_donut(conn, sender_name) |> IO.inspect
    conn |> redirect(to: Routes.page_path(conn, :logged_in))
      # conn
      #   |> put_flash(:info, "Incorrect name.")
      #   |> redirect(to: Routes.page_path(conn, :logged_in))
  end
end
