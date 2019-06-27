defmodule Donuts.Slack.CommandsHandler do
    @oauth_token Application.get_env(:donuts, :oauth_token)
    @donuts_channel Application.get_env(:donuts, :donuts_channel_id)
    @expiration_days Application.get_env(:donuts, :donuts_expiration_days)
    @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
    @client_id Application.get_env(:donuts, :client_id)
    @client_secret Application.get_env(:donuts, :client_secret)
  
    alias Donuts.Accounts
    alias Donuts.RoundPies.Donut
    alias Donuts.RoundPies
    alias Donuts.Helpers.HTTPHelper
    alias Donuts.Slack.Operations
  
    # defguard is_add_via_slack(cmd_ingridients) when List.first(cmd_ingridients) == "donuts_add" and length(cmd_ingridients) == 2

    def handle_slack_command(%{
    "command" => command,
    "text" => params,
    "user_id" => sender_id,
    "channel_id" => channel_id}) do
        cmd_params = params |> String.split(" ", trim: true)
        process_slack_command(command, cmd_params, sender_id, channel_id)
    end

    def handle_slack_command(_params), do: :unhandled

    def process_slack_command("/donuts", ["list" | params], from_id, channel_id)
    when params == [] do
      message = get_active_donuts() |> URI.encode()
      {:ok, "donuts", :list, message, from_id, channel_id} |> Operations.message()
    end

    def process_slack_command("/donuts", ["release", target_name | params], from_id, channel_id)
    when params == [] do
      target_name = target_name |> String.trim("@") |> IO.inspect
      target = Accounts.get_by_slack_name(target_name)
      initialize_release(target, from_id, channel_id)
    end

    def process_slack_command("/donuts", ["remove", target_name | params], from_id, channel_id)
    when params == [] do
      target_name = target_name |> String.trim("@") |> IO.inspect
      target = Accounts.get_by_slack_name(target_name)
      check_self_sending(target.id, from_id)
      |> remove_donut(target, from_id, channel_id)
    end

    def process_slack_command("/donuts", [name | params], from_id, channel_id)
    when params == [] and name != nil do
        process_adding_donut(name, from_id, channel_id)
    end

    def process_slack_command(_), do: :unhandled

    def process_adding_donut(sender_name, target_id, channel_id) do
      sender_name = sender_name |> String.trim("@") |> IO.inspect
      sender = Accounts.get_by_slack_name(sender_name)    
      initialize_donut(sender, target_id, channel_id)
    end

    def check_self_sending(sender, receiver), do: (sender == receiver)

    def initialize_donut(sender, target_id, channel_id) when sender == [] or sender == nil do
      {:error, "donuts", :add, target_id, channel_id} |> Operations.message()
    end

    def initialize_donut(sender, target_id, channel_id) do
      guilty = Accounts.get_by_slack_id(target_id)

      check_self_sending(guilty.name, sender.name)
      |> add_donut(guilty, sender.name, channel_id)
      |> Operations.message()
    end

    def initialize_release(target, from_id, channel_id) do
      check_self_sending(target.id, from_id)
      |> release_donut(target, from_id, channel_id)
    end

    def initialize_release(target, from_id, channel_id) when target == [] or target == nil do
      message = "Wrong name of release target." |> URI.encode()
      {:error, "donuts", :release, from_id, message, channel_id} |> Operations.message()
    end

    def initialize_remove(target, from_id, channel_id) do
      check_self_sending(target.id, from_id)
      |> remove_donut(target, from_id, channel_id)
    end

    def initialize_remove(target, from_id, channel_id) when target == [] or target == nil do
      message = "Wrong name of remove target." |> URI.encode()
      {:error, "donuts", :remove, from_id, message, channel_id} |> Operations.message()
    end

    def add_donut(false, guilty, sender_name, channel_id) do
      %{
        sender: sender_name,
        guilty: guilty.name,
        user_id: guilty.id,
        expiration_date:
          DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
        delivered: false
      }
      |> RoundPies.create_donut()
      {:ok, "donuts", sender_name, guilty.slack_name, channel_id}
    end

    def add_donut(true, guilty, sender, channel_id), do: {:self_sending, "donuts", :add, guilty.slack_id, channel_id}

    def release_donut(false, target, from_id, channel_id) do
      release_target =
        target.id
        |> RoundPies.get_oldest_active_donut()
        |> save_release(target, from_id, channel_id)
    end

    def save_release(nil, target, from_id, channel_id) do
      message = "<@#{target.slack_name}> has no donut debts!" |> URI.encode()
      {:error, "donuts", :release, from_id, message, channel_id} |> Operations.message()
    end

    def save_release(release_target, target, from_id, channel_id) do
      case RoundPies.update_donut(release_target, %{:delivered => true}) do
        {:ok, donut} ->
          message = "Donuts delivered - confirmed by <@#{from_id}>! Thanks <@#{target.slack_name}>!" |> URI.encode()
          {:ok, "donuts", :release, from_id, message, channel_id} |> Operations.message()
  
        {:error, %Ecto.Changeset{} = changeset} ->
          message = "Oops! Error in changeset!" |> URI.encode()
          {:error, "donuts", :release, from_id, message, channel_id} |> Operations.message()
      end
    end

    def remove_donut(false, target, from_id, channel_id) do
      remove_target =
        target.id
        |> RoundPies.get_newest_active_donut()
        |> save_remove(target, from_id, channel_id)
    end

    def save_remove(nil, target, from_id, channel_id) do
      message = "<@#{target.slack_name}> has no donut debts!" |> URI.encode()
      {:error, "donuts", :remove, from_id, message, channel_id} |> Operations.message()
    end

    def save_remove(remove_target, target, from_id, channel_id) do
      RoundPies.delete_donut()
      message = "Newest donut of <@#{target.slack_name}> removed." |> URI.encode()
      {:ok, "donuts", :remove, from_id, message, channel_id} |> Operations.message()
    end

    def remove_donut(true, target, from_id, channel_id) do
        message = "Self remove is forbidden ;)." |> URI.encode()
        {:error, "donuts", :remove, from_id, message, channel_id} |> Operations.message()
    end

    def release_donut(true, target, from_id, channel_id) do
      message = "Self release is forbidden ;)" |> URI.encode()
      {:error, "donuts", :release, from_id, message, channel_id} |> Operations.message()
    end

    def get_active_donuts() do
      active_donuts =
        RoundPies.get_all()
        |> Enum.reduce("Active donuts: \n", fn donut, message ->
          donut
          delivered = donut.delivered
  
          if delivered == false do
            message = "#{message}\n> Guilty: #{donut.guilty} \n"
            message = "#{message}\n> Sender: #{donut.sender} \n"
  
            exp_date =
              donut.expiration_date
              |> DateTime.to_date()
              |> Date.to_string()
  
            message = "#{message}\n> Expiration date: #{exp_date} \n"
            message = "#{message} ---------------------------------- \n"
          else
            message
          end
        end)
    end
end