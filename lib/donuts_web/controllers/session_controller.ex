defmodule DonutsWeb.SessionController do
  use DonutsWeb, :controller
  @client_id Application.get_env(:donuts, :client_id)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  alias Donuts.Sessions
  alias Donuts.Sessions.Session
  alias Donuts.Accounts
  alias Donuts.SlackCommunicator.Auth
  alias Donuts.Helpers.HTTPHelper

  def sign_in(conn, _params) do
    redirect = @redirect_uri_auth |> URI.encode()

    link =
      "https://slack.com/oauth/authorize?scope=identity.basic&client_id=#{@client_id}&redirect_uri=#{
        redirect
      }"

    render(conn, "sign-in.html", link: link)
  end

  def auth(conn, params) do
    token_info = 
      params 
      |> Auth.get_code()
      |> Auth.get_token_info()

    case Sessions.auth_user(token_info) do
      {:ok, nil} ->
        conn
        |> put_session(:token, token_info["access_token"])
        |> redirect(to: Routes.page_path(conn, :index))
      {:invalid_user, nil} ->
        conn
        |> put_flash(:info, "Sorry, it seems you are not in our user database.")
        |> redirect(to: Routes.page_path(conn, :index))
      {:invalid_request, nil} ->
        conn
        |> put_flash(:info, "Sorry, it seems we have some kind of problem with logging in.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

end
