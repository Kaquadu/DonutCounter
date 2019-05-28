defmodule Donuts.Donuts.Donut do
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "donuts" do
    field :sender, :string
    field :guilty, :string
    field :expiration_date, :utc_datetime

    timestamps()
  end

  def changeset(donut, attrs) do
    attrs =
    attrs
    |> Map.put(:expiration_date, DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second))

    donut
    |> cast(attrs, [:sender, :guilty, :expiration_date])
    |> validate_required([:sender, :guilty, :expiration_date])
  end

end
