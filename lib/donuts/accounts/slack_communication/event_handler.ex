defmodule Slack.EventHandler do

    def handle_slack_event(%{"type" => "team_join"} = event) do
        usr_raw = event["user"]
        %{
            "slack_id" => usr_raw["id"],
            "name" => usr_raw["profile"]["real_name"],
            "is_admin" => usr_raw["is_admin"],
            "slack_name" => slack_name = usr_raw["name"]
          }
          |> Accounts.create_user()
    end
end