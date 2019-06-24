defmodule Donuts.Helpers.Auth do
  @client_id Application.get_env(:donuts, :client_id)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  @redirect_uri_loggedin Application.get_env(:donuts, :redirect_uri_loggedin)
  @client_secret Application.get_env(:donuts, :client_secret)
  alias Donuts.Helpers.HTTPHelper
  alias Donuts.Sessions.Session
  alias Donuts.Sessions
  alias Donuts.Accounts

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

  def create_session(response) do
    token = response["access_token"]

    Donuts.RoundPies.SlackCommunicator.get_all_users()
    |> Donuts.Background.UserManager.assign_users()

    user_id =
      response["user"]["id"]
      |> Accounts.get_by_slack_id()
      |> Map.get(:id)

    Sessions.create_session(%{:token => token, :user_id => user_id})
  end
end
