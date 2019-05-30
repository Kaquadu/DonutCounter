defmodule Donuts.Repo.Migrations.CreateDonuts do
  use Ecto.Migration

  def change do
    create table(:donuts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :sender, :string
      add :guilty, :string
      add :delivered, :boolean
      add :expiration_date, :utc_datetime
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end

end
