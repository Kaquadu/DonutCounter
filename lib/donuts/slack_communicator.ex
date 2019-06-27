defmodule Donuts.SlackCommunicator do
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
  
    # defguard is_add_via_slack(cmd_ingridients) when List.first(cmd_ingridients) == "donuts_add" and length(cmd_ingridients) == 2
  
    def get_all_users() do
      "https://slack.com/api/users.list?token=#{@oauth_token}&pretty=1"
      |> HTTPHelper.get_body()
    end
  
    def send_message_to_channel(channel, text) do
      "https://slack.com/api/chat.postMessage?token=#{@oauth_token}&channel=#{channel}&text=#{text}&as_user=false"
      |> HTTPHelper.get_body()
    end

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
        
    end

    def process_slack_command(_), do: :unhandled
end