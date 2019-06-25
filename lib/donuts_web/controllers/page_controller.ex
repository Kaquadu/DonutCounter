defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller
  alias Donuts.Sessions
  alias Donuts.Sessions.Session
  alias Donuts.Accounts
  alias Donuts.Account.User
  alias Donuts.Helpers.Auth
  alias Donuts.Helpers.HTTPHelper
  alias Donuts.RoundPies

  plug(DonutsWeb.Plugs.LoginStatus when action in [:index, :logged_in, :add_donut, :user_view])

  def index(conn, _params) do
    user_stats = Accounts.get_statistics()
    render(conn, "index.html", stats: user_stats)
  end

  def user_view(conn, user) do
    user_id = Accounts.get_by_real_name(user["username"]) |> Map.get(:id)
    delivered_donuts =
      RoundPies.get_delivered_donuts(user_id)
      |> Enum.reduce([], fn donut, acc -> 
        mapped = donut |> Map.from_struct()
        acc = [mapped | acc]
      end) |> IO.inspect
    expired_donuts = RoundPies.get_expired_donuts(user_id)
      |> Enum.reduce([], fn donut, acc -> 
        mapped = donut |> Map.from_struct()
        acc = [mapped | acc]
      end) |> IO.inspect
    active_donuts = RoundPies.get_active_donuts(user_id)
      |> Enum.reduce([], fn donut, acc -> 
        mapped = donut |> Map.from_struct()
        acc = [mapped | acc]
      end) |> IO.inspect
    render(conn, "user_view.html", user: user, delivered: delivered_donuts, 
                                    expired: expired_donuts, active: active_donuts)
  end

  def release_target(conn, target) do
    target |> IO.inspect
    |> RoundPies.update_donut(%{:delivered => true})
    
    conn |> redirect(to: Routes.page_path(conn, :index))
  end

  # only change in router when you have to verify your app in slack
  def event_test(conn, params) do
    conn |> send_resp(200, params["challange"])
  end

  def event_handler(conn, %{"event" => event}) do
    Donuts.RoundPies.handle_slack_event(event)
    conn |> send_resp(200, "")
  end

  def add_donut(conn, %{"donut" => %{"sender_name" => sender_name}}) do
    sender = Donuts.Accounts.get_by_real_name(sender_name)

    if sender == nil or sender == [] do
      conn
      |> put_flash(:info, "Incorrect name.")
      |> render("donuted.html", success: false)
    else
      target_name = Sessions.get_current_user_name(conn)
      target_id = Accounts.get_by_real_name(target_name) |> Map.get(:id)
      {status, donut} = Donuts.RoundPies.add_new_donut(sender_name, target_name, target_id)
      conn |> render("donuted.html", success: true)
    end
  end
end
