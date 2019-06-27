defmodule Donuts.Background.UserManager do
  use GenServer
  alias Donuts.Accounts
  alias Donuts.Slack

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
        assign_users()

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

  def assign_users() do
    Slack.Operations.get_all_users()
      |> Map.get("members")
      |> update_users()
  end

  def update_users(members) when is_nil(members), do: :ok
  def update_users(members) when length(members) == 0, do: :ok

  def update_users(members) do
    members
    |> Enum.each(fn usr_raw ->
      slack_id = usr_raw["id"]
      Accounts.get_by_slack_id(slack_id) |> update_user(usr_raw)
    end)
  end

  def update_user(db_usr, usr_raw) when db_usr == [] or db_usr == nil do
    if (usr_raw["id"] != "USLACKBOT") do
      %{"slack_id" => usr_raw["id"], 
        "name" => usr_raw["profile"]["real_name"], 
        "is_admin" => usr_raw["is_admin"], 
        "slack_name" => slack_name = usr_raw["name"]}
        |> Accounts.create_user()
    end
  end

  def update_user(db_usr, usr_raw) do
    case usr_raw["deleted"] do
      false ->
        attrs = %{"slack_id" => usr_raw["id"], 
          "name" => usr_raw["profile"]["real_name"], 
          "is_admin" => usr_raw["is_admin"], 
          "slack_name" => slack_name = usr_raw["name"]}
        Accounts.update_user(db_usr, attrs)
      true ->
        Accounts.delete_user(db_usr)
    end
  end
end
