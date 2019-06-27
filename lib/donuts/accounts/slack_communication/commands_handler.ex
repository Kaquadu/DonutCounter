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
    "user_id" => sender_id}) do
        cmd_params = params |> String.split(" ", trim: true)
        process_slack_command(command, cmd_params, sender_id)
    end

    def handle_slack_command(_params), do: :unhandled

    def process_slack_command(command, [name | params], sender_id)
    when command == "donuts" and params == [] and name != nil do
        process_adding_donut(name, sender_id)
    end

    def process_slack_command(_), do: :unhandled

    def process_adding_donut(sender_name, target_id) do
      sender = Accounts.get_by_slack_name(sender_name)    
      initialize_donut(sender, target_id)
    end

    def check_self_sending(sender, receiver), do: (sender == receiver)

    def initialize_donut(sender, _) when sender == [] or sender == nil do
      {:error, "donuts", :wrong_user} |> Operations.message()
    end

    def initialize_donut(sender, target_id) do
      guilty = Accounts.get_by_slack_id(target_id)

      check_self_sending(guilty.name, sender.name)
      |> add_donut(guilty, sender.name)
      |> Operations.message()
    end

    def add_donut(false, guilty, sender_name) do
      %{
        sender: sender_name,
        guilty: guilty.name,
        user_id: guilty.id,
        expiration_date:
          DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
        delivered: false
      }
      |> RoundPies.create_donut()
      {:ok, "donuts", sender_name, guilty.slack_name}
    end

    def add_donut(true, _), do: {:error, "donuts", :self_sending}

end