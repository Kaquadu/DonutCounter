defmodule Donuts.Sessions do
  import Ecto.Query, warn: false
  alias Plug.Conn
  alias Donuts.Accounts
  alias Donuts.Helpers.Auth
  alias Donuts.Repo
  alias Donuts.Sessions.Session
  alias Donuts.Slack
  @ttl Application.get_env(:donuts, :ttl_seconds)
  @salt Application.get_env(:donuts, :bcrypt_salt)

  def get_all() do
    Repo.all(Session)
  end

  def check_token_activity(nil) do
    []
  end

  def check_token_activity(token) do
    DateTime.add(DateTime.utc_now(), -1 * @ttl, :second)
    token_h = Bcrypt.Base.hash_password(token, @salt)

    Repo.all(
      from(s in Session,
        where:
          s.inserted_at >
            ^DateTime.add(DateTime.utc_now(), -1 * @ttl, :second),
        where: s.token == ^token_h
      )
    )
  end

  def create_session(attrs) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  def auth_user(token_info = %{"ok" => true, "user" => %{"id" => user_id}}) do
    if Accounts.get_by_slack_id(user_id) do
      initialize_session(token_info)
      :ok
    else
      user = Slack.Operations.get_user_info(user_id) |> Map.get("user")

      %{
        "slack_id" => user["id"],
        "name" => user["profile"]["real_name"],
        "is_admin" => user["is_admin"],
        "slack_name" => user["name"]
      }
      |> Accounts.create_user()

      initialize_session(token_info)
      :ok
    end
  end

  def auth_user(%{"ok" => false}) do
    :invalid_request
  end

  def initialize_session(%{"access_token" => token, "user" => %{"id" => slack_id}}) do
    user_id =
      slack_id
      |> Accounts.get_by_slack_id()
      |> Map.get(:id)

    create_session(%{token: token, user_id: user_id})
  end

  def logged_in?(conn) do
    conn |> Conn.get_session(:token) |> active_token?()
  end

  defp active_token?(nil) do
    false
  end

  defp active_token?(token) do
    !(check_token_activity(token) in [[], nil])
  end

  def get_current_user_name(conn) do
    active_session_tokens =
      conn
      |> Conn.get_session(:token)
      |> check_token_activity()
      |> get_name_from_token()
  end

  def get_name_from_token(active_tokens)
      when active_tokens in [[], nil] do
    "Not active"
  end

  def get_name_from_token([active_token | _]) do
    Accounts.get_by_id(active_token.user_id).name
  end

  def can_release?(conn, user_name) do
    user_name != get_current_user_name(conn)
  end
end
