defmodule Donuts.Sessions do
  import Ecto.Query, warn: false
  alias Donuts.Accounts
  alias Donuts.Auth
  alias Donuts.Repo
  alias Donuts.Sessions.Session
  @ttl Application.get_env(:donuts, :ttl_seconds)
  @salt Application.get_env(:donuts, :bcrypt_salt)

  def get_all() do
    Repo.all(Session)
  end

  def check_active(token) do
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
      Auth.create_session(token_info)
      {:ok, nil}
    else
      {:invalid_user, nil}
    end
  end

  def auth_user(%{"ok" => false}) do
    {:invalid_request, nil}
  end
end
