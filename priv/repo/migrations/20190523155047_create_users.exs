defmodule Donuts.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :ID, :string, primary_key: true
      add :name, :string

      timestamps()
    end

    create unique_index(:users, [:ID])
  end
end
