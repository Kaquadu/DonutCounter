defmodule Donuts.Helpers.SlackCommunicator do
  @oauth_token Application.get_env(:donuts, :oauth_token)
  @donuts_channel Application.get_env(:donuts, :donuts_channel_id)
  alias Donuts.Helpers.HTTPHelper
  alias Donuts.Accounts
  alias Donuts.Donuts.Donut

  def get_all_users() do
    "https://slack.com/api/users.list?token=#{@oauth_token}&pretty=1"
    |> HTTPHelper.get_body
  end

  def handle_event(%{
    "type" => event_type,
    "channel" => event_channel,
    "text" => event_text,
    "user" => user_id
    }) do
    if event_type == "message" and event_channel == @donuts_channel do
      process_donut_command(event_text, user_id)
    end
  end

  defp process_donut_command(command, user_id) do
    splitted_cmd = command |> String.split()
    command = splitted_cmd |> List.pop_at(0)
    fname = splitted_cmd |> List.pop_at(1)
    sname = splitted_cmd |> List.pop_at(2)
    name = fname <> " " <> sname
    if (Accounts.get_by_real_name(name)) and command == "add" do
      sender = Accounts.get_by_slack_id(user_id)
      donut = %{}
      |> Map.put("sender", sender)
      |> Map.put("guilty", name)
      Donuts.Donuts.create_donut(donut)
    else if (Accounts.get_by_real_name(name)) and command == "remove" do
      #delete donut

    else
      #not a correct cmd
    end
  end
  end

end
