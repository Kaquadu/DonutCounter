defmodule Donuts.Sessions do
  import Ecto.Query, warn: false
  alias Plug.Conn
  alias Donuts.Accounts
  alias Donuts.Helpers.Auth
  alias Donuts.Repo
  alias Donuts.Sessions.Session
  @ttl Application.get_env(:donuts, :ttl_seconds)
  @salt Application.get_env(:donuts, :bcrypt_salt)

  def get_all() do
    Repo.all(Session)
  end

  def check_token_activity(nil) do
    nil
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
      make_session(token_info)
      {:ok, nil}
    else
      {:invalid_user, nil}
    end
  end

  def auth_user(%{"ok" => false}) do
    {:invalid_request, nil}
  end

  def make_session(response) do
    token = response["access_token"]

    Donuts.SlackCommunicator.get_all_users()
    |> Donuts.Background.UserManager.assign_users()

    user_id =
      response["user"]["id"]
      |> Accounts.get_by_slack_id()
      |> Map.get(:id)

    create_session(%{:token => token, :user_id => user_id})
  end

  def logged_in?(conn) do
    session_token = conn |> Conn.get_session(:token)

    if session_token do
      active_tks = check_token_activity(session_token)

      case active_tks do
        [] -> false
        nil -> false
        _ -> true
      end
    else
      false
    end
  end

  def get_current_user_name(conn) do
    active_session_tokens = 
      conn 
        |> Conn.get_session(:token)
        |> check_token_activity()

    case active_session_tokens do
      [] ->
        "Not active"

      nil ->
        "Not active"

      _ ->
        active_session_tokens
        |> List.first()
        |> Map.get(:user_id)
        |> Accounts.get_by_id()
        |> Map.get(:name)
    end
  end

  def can_release?(conn, user_name) do
    current_user = get_current_user_name(conn)
    user_name
    case user_name do
      current_user -> false
      _ -> true
    end
  end
end
