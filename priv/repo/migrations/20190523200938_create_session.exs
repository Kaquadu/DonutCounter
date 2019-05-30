defmodule Donuts.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :token, :string
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

  end
end
