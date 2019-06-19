defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller
  alias Donuts.Sessions.Session
  alias Donuts.Accounts
  alias Donuts.Helpers.Auth
  alias Donuts.Helpers.HTTPHelper

  plug(DonutsWeb.Plugs.LoginStatus when action in [:logged_in, :add_donut])

  def index(conn, _params) do
    if Donuts.Sessions.Session.logged_in?(conn) != [] and Donuts.Sessions.Session.logged_in?(conn) != nil do
      conn
        |> redirect(to: "/loggedin")
    else
      render(conn, "index.html")
    end
  end

  def logged_in(conn, _params) do
    user_stats = Donuts.Accounts.Statistics.get_statistics()
    render(conn, "logged_in.html", stats: user_stats)
  end

  # only change in router when you have to verify your app in slack
  def event_test(conn, params) do
    challange = Map.get(params, "challenge")
    conn |> send_resp(200, challange)
  end

  def event_handler(conn, %{"event" => event}) do
    Donuts.Donuts.handle_slack_event(event)
    conn |> send_resp(200, "")
  end

  def add_donut(conn, %{"donut" => %{"sender_name" => sender_name}}) do
    sender = Donuts.Accounts.get_by_real_name(sender_name) |> IO.inspect
    if sender == nil or sender == [] do
      conn
        |> put_flash(:info, "Incorrect name.")
        |> render("logged_in.html", success: false)
    else 
      target_name = Session.get_current_user_name(conn)
      target_id = Accounts.get_by_real_name(target_name) |> Map.get(:id)
      {status, donut} = Donuts.Donuts.add_new_donut(sender_name, target_name, target_id) |> IO.inspect
      conn |> render("logged_in.html", success: true)
    end
  end
end
