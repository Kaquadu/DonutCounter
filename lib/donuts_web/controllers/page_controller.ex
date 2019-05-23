defmodule DonutsWeb.PageController do
  use DonutsWeb, :controller
  alias Donuts.Helpers.Auth
  @client_id Application.get_env(:donuts, :client_id)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  @redirect_uri_loggedin Application.get_env(:donuts, :redirect_uri_loggedin)
  @client_secret Application.get_env(:donuts, :client_secret)

  def index(conn, _params) do
    render conn, "index.html"
  end

  def sign_in(conn, _params) do
    link = "https://slack.com/oauth/authorize?scope=identity.basic&client_id=#{@client_id}&redirect_uri=#{@redirect_uri_auth}"
    render conn, "sign-in.html", link: link
  end

  def auth(conn, params) do
    response = params |> Auth.get_code() |> Auth.get_token_info() |> Auth.create_session()
    redirect(conn, to: "/logged-in")
  end

  def logged_in(conn, _params) do
    render conn, "logged_in.html"
  end
end
