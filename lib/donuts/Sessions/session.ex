defmodule Donuts.Sessions.Session do
  use Donuts.Schema
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

end
