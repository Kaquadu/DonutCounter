defmodule Donuts.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import UUID

  schema "sessions" do
    field :uuid, :string
    field :token, :string
    field :user_id, :string

    timestamps()
  end

  def changeset(session, attrs) do
    attrs =
    attrs
    |> Map.put(:uuid, UUID.uuid1())

    session
    |> cast(attrs, [:uuid, :token, :user_id])
    |> validate_required([:uuid, :token, :user_id])
    |> update_change(:token, &Bcrypt.hash_pwd_salt/1)
    |> unique_constraint(:uuid)
  end

end
