defmodule Donuts.Repo.Migrations.AddSlackNameToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :slack_name, :string
    end
  end
end
