defmodule Donuts.Donuts.SlackCommunicator do
  @oauth_token Application.get_env(:donuts, :oauth_token)
  @donuts_channel Application.get_env(:donuts, :donuts_channel_id)
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)
  alias Donuts.Helpers.HTTPHelper
  alias Donuts.Accounts
  alias Donuts.Donuts.Donut

  def get_all_users() do
    "https://slack.com/api/users.list?token=#{@oauth_token}&pretty=1"
    |> HTTPHelper.get_body()
  end

  def send_message_to_channel(channel, text) do
    "https://slack.com/api/chat.postMessage?token=#{@oauth_token}&channel=#{channel}&text=#{text}&as_user=false"
    |> HTTPHelper.get_body()
  end

  def handle_slack_event(%{
    "type" => event_type,
    "channel" => event_channel,
    "text" => event_text,
    "user" => user_id
    }) do
    if event_type == "message" do
      process_donut_command(event_text, user_id)
    end
  end

  def handle_slack_event(_params) do
    {:unhandled_event, nil}
  end

  defp process_donut_command(command, sender_id) do
    cmd_ingridients = command |> String.split(" ", trim: true)
    cmd_base = cmd_ingridients |> Enum.at(0)
    case cmd_base do
      "donuts_add" ->
        cmd_fname = cmd_ingridients |> Enum.at(1)
        cmd_lname = cmd_ingridients |> Enum.at(2)
        if (cmd_lname != nil) do
          cmd_sender_name = cmd_fname <> " " <> cmd_lname
        else
          cmd_sender_name = cmd_fname
        end
        if cmd_sender_name != nil do
          add_donut_to_user(cmd_sender_name, sender_id)
          message =  "Succesfuly added donut debt!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        else
          message =  "Oops! Wrong format of your's name!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        end
        {:noreply, nil}
      "donuts_rm" ->
        cmd_donut_id = cmd_ingridients |> Enum.at(1)
        delete_target = Donuts.Donuts.get_by_id(cmd_donut_id)
        if delete_target != nil do
          Donuts.Donuts.delete_donut(delete_target)
          name = delete_target |> Map.get(:guilty)
          message =  "Deleted donut debt of #{name}!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        else
          message =  "Oops! Wrong ID of the donut!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        end
        {:noreply, nil}
      "donuts_release" ->
        cmd_donut_id = cmd_ingridients |> Enum.at(1)
        release_target = Donuts.Donuts.get_by_id(cmd_donut_id)
        if release_target != nil do
          case Donuts.Donuts.update_donut(release_target, %{:delivered => true}) do
            {:ok, donut} ->
              message =  "Released successfully!" |> URI.encode()
              send_message_to_channel(@donuts_channel, message)
            {:error, %Ecto.Changeset{} = changeset} ->
              message =  "Oops! Error in changeset!" |> URI.encode()
              send_message_to_channel(@donuts_channel, message)
          end
        else
          message =  "Oops! Wrong ID of the donut!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        end
        {:noreply, nil}
      "donuts_help" ->
        message =  "Commands: \n
          donuts_add name surename \n
          donuts_release donut_uuid \n
          donuts_rm donut_uuid \n
          donuts_info \n
          donuts_help" |> URI.encode()
        send_message_to_channel(@donuts_channel, message)
        {:noreply, nil}
      "donuts_info" ->
        active_donuts = get_active_donuts()
        if active_donuts != nil do
          active_donuts = active_donuts |> URI.encode()
          send_message_to_channel(@donuts_channel, active_donuts)
        else
          message =  "No active donut debts!" |> URI.encode()
          send_message_to_channel(@donuts_channel, message)
        end
        {:noreply, nil}
      _other ->
        # message = "Oops! Wrong command!" |> URI.encode()
        # send_message_to_channel(@donuts_channel, message)
        {:noreply, nil}
    end
  end

  def add_donut_to_user(sender_name, target_id) do
    if Accounts.get_by_real_name(sender_name) != nil do
      target_name = Accounts.get_by_slack_id(target_id) |> Map.get(:name)
      target_id = Accounts.get_by_slack_id(target_id) |> Map.get(:id)
      %{}
        |> Map.put(:sender, sender_name)
        |> Map.put(:guilty, target_name)
        |> Map.put(:user_id, target_id)
        |> Map.put(:expiration_date, DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second))
        |> Map.put(:delivered, false)
        |> Donuts.Donuts.create_donut()
    else
      message = "Oops! There is no such person like #{sender_name}!" |> URI.encode()
      send_message_to_channel(@donuts_channel, message)
    end
  end

  def get_active_donuts() do
    active_donuts =
      Donuts.Donuts.get_all()
      |> Enum.reduce("Active donuts: \n", fn donut, message ->
        donut |> IO.inspect
        delivered = donut |> Map.get(:delivered) |> IO.inspect
        if delivered == false do
          message = message <> "Guilty:" <> " " <> Map.get(donut, :guilty) <> " | "
          message = message <> "Sender:" <> " " <> Map.get(donut, :sender) <> " | "
          exp_date =
            Map.get(donut, :expiration_date)
            |> DateTime.to_date()
            |> Date.to_string()
          message = message <> "Expiration date:" <> " " <> exp_date <> " | "
          message = message <> "ID:" <> " " <> Map.get(donut, :id) <> "\n"
        else
          message
        end
      end)
  end

end
