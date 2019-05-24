defmodule Donuts.Repo.Migrations.CreateDonuts do
  use Ecto.Migration

  def change do
    create table(:donuts) do
      add :uuid, :uuid, primary_key: true
      add :sender, :string
      add :guilty, :string
      add :comment, :text
      add :expiration_date, :utc_datetime

      timestamps()
    end
  end

end
