defmodule Donuts.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import UUID

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "sessions" do
    field :token, :string
    field :user_id, :string

    timestamps()
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:token, :user_id])
    |> validate_required([:token, :user_id])
    |> update_change(:token, &Bcrypt.hash_pwd_salt/1)
  end

end
