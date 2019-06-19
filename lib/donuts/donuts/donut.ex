defmodule Donuts.RoundPies.Donut do
  use Donuts.Schema

  schema "donuts" do
    field(:sender, :string)
    field(:guilty, :string)
    field(:delivered, :boolean)
    field(:expiration_date, :utc_datetime)

    belongs_to(:user, Donuts.Accounts.User)
    timestamps()
  end

  def changeset(donut, attrs) do
    donut
    |> cast(attrs, [:sender, :guilty, :delivered, :user_id, :expiration_date])
    |> validate_required([:sender, :guilty, :delivered, :user_id, :expiration_date])
  end
end
