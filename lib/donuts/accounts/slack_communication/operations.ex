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

  def send_message_to_channel(channel, text) do
    "https://slack.com/api/chat.postMessage?token=#{@oauth_token}&channel=#{channel}&text=#{text}&as_user=false"
    |> HTTPHelper.get_body()
  end

  def send_ephermal(message, receiver) do
    {status, attachments} = %{
      pretext: "pretext",
      text: message
    } |> Poison.encode()
    "https://slack.com/api/chat.postEphemeral?token=#{@oauth_token}&channel=#{@donuts_channel}&attachments=#{attachments}&text=#{message}&user=#{receiver}"
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
    |> HTTPHelper.get_body()
  end

  def message({:ok, "donuts", sender_name, guilty}) do
    message = "Mmmmm... <@#{guilty}> just owes us some donuts thanks to <@#{sender_name}>'s vigilance" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def message({:error, "donuts", :wrong_user, user}) do
    message = "Wrong user" |> URI.encode()
    send_ephermal(message, user)
    #send_message_to_channel(@donuts_channel, message)
  end

  def message({:error, "donuts", :self_sending}) do
    message = "Self sending" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end
end