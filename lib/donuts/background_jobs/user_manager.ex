defmodule Donuts.Background.UserManager do
  use GenServer
  alias Donuts.Helpers.SlackCommunicator
  alias Donuts.Accounts

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    # Schedule work to be performed on start
    schedule(1)
    {:ok, state}
  end

  def handle_info(message, state) do
    case message do
      :update_db ->
        Donuts.Helpers.SlackCommunicator.get_all_users()
        |> get_user_data()
        schedule(5*60*1000)
        {:noreply, state}
      end
  end


  def schedule(time) do
    Process.send_after(self(), :update_db, time)
  end

  def get_user_data(raw_data) do

    if (raw_data == %{"error" => "token_revoked", "ok" => false}) do
      IO.puts "Error - Token revoked"
      IO.inspect raw_data
    else
      raw_data
      |> Map.get("members")
      |> Enum.each(fn usr_raw ->
        slack_id = usr_raw |> Map.get("id")
        if !Accounts.get_by_slack_id(slack_id) do
          slack_id = usr_raw |> Map.get("id")
          real_name = usr_raw |> Map.get("profile") |> Map.get("real_name")
          is_admin = usr_raw |> Map.get("is_admin")

          %{}
          |> Map.put("slack_id", slack_id)
          |> Map.put("name", real_name)
          |> Map.put("is_admin", is_admin)
          |> Accounts.create_user()
        end
      end)
    end

  end
end
