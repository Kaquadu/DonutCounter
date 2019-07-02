defmodule Donuts.Slack.EventHandler do
    alias Donuts.Accounts

    def handle_slack_event(event = %{"type" => "team_join"}) do
        usr_raw = event["user"]
        %{
            "slack_id" => usr_raw["id"],
            "name" => usr_raw["profile"]["real_name"],
            "is_admin" => usr_raw["is_admin"],
            "slack_name" => slack_name = usr_raw["name"]
          }
          |> Accounts.create_user()
    end

    def handle_slack_event(event = %{"type" => "user_change"}) do
        usr_raw = event["user"]
        attrs = %{
            "slack_id" => usr_raw["id"],
            "name" => usr_raw["profile"]["real_name"],
            "is_admin" => usr_raw["is_admin"],
            "slack_name" => slack_name = usr_raw["name"]
          }
        Accounts.get_by_slack_id(usr_raw["id"])
        |> Accounts.update_user(attrs)
    end
end