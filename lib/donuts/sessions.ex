defmodule Donuts.Sessions do
  import Ecto.Query, warn: false
  alias Donuts.Repo

  alias Donuts.Sessions.Session

  def create_session(attrs) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end
end
