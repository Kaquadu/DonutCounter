defmodule Donuts.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :uuid, :uuid, primary_key: true
      add :token, :string
      add :user_id, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sessions, [:uuid])
  end
end
