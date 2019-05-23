defmodule Donuts.Helpers.Auth do
  @client_id Application.get_env(:donuts, :client_id)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  @redirect_uri_loggedin Application.get_env(:donuts, :redirect_uri_loggedin)
  @client_secret Application.get_env(:donuts, :client_secret)

  def get_code(params) do
    Map.get(params, "code")
  end

  def get_token_info(code) do
    "https://slack.com/api/oauth.access?client_id=#{@client_id}&client_secret=#{@client_secret}&code=#{code}&redirect_uri=#{@redirect_uri_auth}"
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!()
  end

  def create_session(response) do
    
  end
end
