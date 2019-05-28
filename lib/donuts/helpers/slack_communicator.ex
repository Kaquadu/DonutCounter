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

  def send_message_to_channel(channel, text) do
    "https://slack.com/api/chat.postMessage?token=#{@oauth_token}&channel=#{channel}&text=#{text}&as_user=false"
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
    cmd_ingridients = command |> String.split()
    cmd_base = cmd_ingridients |> Enum.at(0)

    
    fname = splitted_cmd |> Enum.at(1)
    sname = splitted_cmd |> Enum.at(2)
    name = fname <> " " <> sname

  end

end
