defmodule Donuts.Donuts.Donut do
  use Ecto.Schema
  import Ecto.Changeset
  import UUID

  schema "donuts" do
    field :uuid, :string
    field :sender, :string
    field :guilty, :string
    field :comment, :string
    field :expiration_date, :utc_datetime

    timestamps()
  end

  def changeset(donut, attrs) do
    attrs =
    attrs
    |> Map.put(:uuid, UUID.uuid1())
    |> Map.put(:expiration_date, DateTime.utc_now()) |> IO.inspect

    donut
    |> cast(attrs, [:uuid, :sender, :guilty, :comment, :expiration_date])
    |> validate_required([:uuid, :sender, :guilty, :expiration_date])
    |> unique_constraint(:uuid)
  end

end
