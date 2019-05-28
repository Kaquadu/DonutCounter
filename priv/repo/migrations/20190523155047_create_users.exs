defmodule Donuts.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :uuid, primary_key: true
      add :slack_id, :string
      add :name, :string
      add :is_admin, :boolean

      timestamps()
    end

    create unique_index(:users, [:slack_id])
  end
end
