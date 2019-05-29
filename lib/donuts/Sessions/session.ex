defmodule Donuts.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import UUID
  @salt Application.get_env(:donuts, :bcrypt_salt)

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "sessions" do
    field :token, :string
    field :user_id, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    new_token = attrs |> Map.get(:token) |> Bcrypt.Base.hash_password(@salt)
    attrs = attrs |> Map.put(:token, new_token)

    session
    |> cast(attrs, [:token, :user_id])
    |> validate_required([:token, :user_id])
    |> unique_constraint(:uuid)
  end

end
