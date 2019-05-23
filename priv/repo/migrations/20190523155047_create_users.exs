defmodule Donuts.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :ID, :string
      add :name, :string

      timestamps()
    end

    create unique_index(:users, [:ID])
  end
end
