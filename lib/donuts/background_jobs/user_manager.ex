defmodule Donuts.Background.UserManager do
  use GenServer
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
        Donuts.RoundPies.SlackCommunicator.get_all_users()
        |> assign_users()

        schedule(1 * 60 * 1000)
        {:noreply, state}
    end
  end

  def schedule(time) do
    Process.send_after(self(), :update_db, time)
  end

  def get_user_data(%{"error" => "token_revoked", "ok" => false}) do
    IO.puts("---------------------")
    IO.puts("Error - Token revoked")
    IO.puts("---------------------")
  end

  def assign_users(raw_data) do
    members =
      raw_data
      |> Map.get("members")
      |> update_users()
  end

  def update_users(members) when is_nil(members), do: :ok
  def update_users(members) when length(members) == 0, do: :ok

  def update_users(members) do
    members
    |> Enum.each(fn usr_raw ->
      slack_id = usr_raw |> Map.get("id")

      if slack_id != "USLACKBOT" and !Accounts.get_by_slack_id(slack_id) do
        slack_id = usr_raw |> Map.get("id")
        real_name = usr_raw |> Map.get("profile") |> Map.get("real_name")
        is_admin = usr_raw |> Map.get("is_admin")

        %{"slack_id" => slack_id, "name" => real_name, "is_admin" => is_admin}
        |> Accounts.create_user()
      end
    end)
  end
end
