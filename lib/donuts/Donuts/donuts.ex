defmodule Donuts.Donuts.Donut do
  use Ecto.Schema
  import Ecto.Changeset
  import UUID

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "donuts" do
    field :sender, :string
    field :guilty, :string
    field :comment, :string
    field :expiration_date, :utc_datetime

    timestamps()
  end

  def changeset(donut, attrs) do
    attrs =
    attrs
    |> Map.put(:expiration_date, DateTime.utc_now())

    donut
    |> cast(attrs, [:sender, :guilty, :comment, :expiration_date])
    |> validate_required([:sender, :guilty, :expiration_date])
  end

end
