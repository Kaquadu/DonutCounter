defmodule Donuts.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "users" do
    field :slack_id, :string
    field :name, :string
    field :is_admin, :boolean
    timestamps()
  end

  def changeset(user, attrs) do
    user
      |> cast(attrs, [:slack_id, :name])
      |> validate_required([:slack_id, :name])
      |> unique_constraint(:slack_id)
  end
end
