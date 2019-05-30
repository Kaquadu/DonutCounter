defmodule Donuts.Accounts.User do
  use Donuts.Schema
  import Ecto.Changeset

  schema "users" do
    field :slack_id, :string
    field :name, :string
    field :is_admin, :boolean

    has_many :donuts, Donuts.Donuts.Donut, on_delete: :delete_all
    has_many :sessions, Donuts.Sessions.Session, on_delete: :delete_all
    timestamps()
  end

  def changeset(user, attrs) do
    user
      |> cast(attrs, [:slack_id, :name])
      |> validate_required([:slack_id, :name])
      |> unique_constraint(:slack_id)
  end
end
