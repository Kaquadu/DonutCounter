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
    |> HTTPHelper.get_body()
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

  defp process_donut_command(command, sender_id) do
    cmd_ingridients = command |> String.split(" ", trim: true)
    cmd_base = cmd_ingridients |> Enum.at(0)
    case cmd_base do
      "add" ->
        cmd_fname = cmd_ingridients |> Enum.at(1)
        cmd_lname = cmd_ingridients |> Enum.at(2)
        if cmd_fname != nil and cmd_lname != nil do
          cmd_target_name = cmd_fname <> " " <> cmd_lname
          add_donut_to_user(cmd_target_name, sender_id)
        else
          message =  "Oops! Wrong format of the guilty's name!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        end
        {:noreply, nil}
      "remove" ->
        cmd_donut_id = cmd_ingridients |> Enum.at(1)
        delete_target = Donuts.Donuts.get_by_id(cmd_donut_id)
        if delete_target != nil do
          Donuts.Donuts.delete_donut()
        else
          message =  "Oops! Wrong ID of the donut!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        end
        {:noreply, nil}
      "help" ->
        message =  "Commands: \n
          add name surename \n
          remove uuid \n
          info \n
          help" |> URI.encode()
        send_message_to_channel(@donuts_channel, message)
        {:noreply, nil}
      "info" ->
        active_donuts = get_active_donuts() |> URI.encode()
        send_message_to_channel(@donuts_channel, active_donuts)
        {:noreply, nil}
      _ ->
        message = "Oops! Wrong command!" |> URI.encode()
        send_message_to_channel(@donuts_channel, message)
        {:noreply, nil}
    end
  end

  def add_donut_to_user(target_name, sender_id) do
    if Accounts.get_by_real_name(target_name) != nil do
      sender_name = Accounts.get_by_slack_id(sender_id) |> Map.get(:name)
      %{}
        |> Map.put(:sender, sender_name)
        |> Map.put(:guilty, target_name)
        |> Donuts.Donuts.create_donut()
    else
      message = "Oops! There is no such person!" |> URI.encode()
      send_message_to_channel(@donuts_channel, message)
    end
  end

  def get_active_donuts() do
    active_donuts =
      Donuts.Donuts.get_all()
      |> Enum.reduce("", fn donut, message ->
        message = message <> "Guilty:" <> " " <> Map.get(donut, :guilty) <> " | "
        message = message <> "Sender:" <> " " <> Map.get(donut, :sender) <> " | "
        exp_date =
          Map.get(donut, :expiration_date)
          |> DateTime.to_date()
          |> Date.to_string()
        message = message <> "Expiration date:" <> " " <> exp_date <> " | "
        message = message <> "ID:" <> " " <> Map.get(donut, :uuid) <> "\n"
      end)
  end

end
