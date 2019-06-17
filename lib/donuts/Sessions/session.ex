defmodule Donuts.Sessions.Session do
  use Donuts.Schema
  alias Plug.Conn
  alias Donuts.Sessions
  alias Donuts.Accounts

  @salt Application.get_env(:donuts, :bcrypt_salt)

  schema "sessions" do
    field :token, :string

    belongs_to :user, Donuts.Accounts.User
    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    new_token = attrs |> Map.get(:token) |> Bcrypt.Base.hash_password(@salt)
    attrs = attrs |> Map.put(:token, new_token)

    session
      |> cast(attrs, [:token, :user_id])
      |> validate_required([:token, :user_id])
  end


  def logged_in?(conn) do
    session_token = conn |> Conn.get_session(:token)
    if session_token, do: Sessions.check_active(session_token)
  end

  def get_current_user_name(conn) do
      list = logged_in?(conn)
      if list != [] and list != nil do
        list
          |> List.first()
          |> Map.get(:user_id)
          |> Accounts.get_by_id()
          |> Map.get(:name)
      end
  end
end
