defmodule Donuts.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :ID, :string
    field :name, :string
    timestamps()
  end

  def changeset(user, attrs) do
    user
      |> cast(attrs, [:ID, :name])
      |> validate_required([:ID, :name])
      |> unique_constraint(:ID)
  end
end
