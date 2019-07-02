defmodule Donuts.Slack.Operations do
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

  def get_user_info(id) do
    "https://slack.com/api/users.info?token=#{@oauth_token}&user=#{id}"
    |> HTTPHelper.get_body()
  end

  def send_message_to_channel(channel, text) do
    "https://slack.com/api/chat.postMessage?token=#{@oauth_token}&channel=#{channel}&text=#{text}&as_user=false"
    |> HTTPHelper.get_body()
  end

  def send_ephemeral(message, receiver, channel_id) do
    "https://slack.com/api/chat.postEphemeral?token=#{@oauth_token}&channel=#{channel_id}&text=#{
      message
    }&user=#{receiver}"
    |> HTTPHelper.get_body()
  end

  def get_code(params) do
    params["code"]
  end

  def get_token_info(code) do
    redirect = @redirect_uri_auth |> URI.encode()

    "https://slack.com/api/oauth.access?client_id=#{@client_id}&client_secret=#{@client_secret}&code=#{
      code
    }&redirect_uri=#{redirect}"
    |> HTTPHelper.get_body() |> IO.inspect()
  end

  def message({:ok, "donuts", user, message, channel_id}) do
    send_message_to_channel(@donuts_channel, message)
    send_ephemeral(message, user, channel_id)
  end

  def message({:info, "donuts", from_id, message, channel_id}) do
    send_ephemeral(message, from_id, channel_id)
  end

  def message({:error, "donuts", from_id, message, channel_id}) do
    send_ephemeral(message, from_id, channel_id)
  end
end
