defmodule Donuts.Sessions do
  import Ecto.Query, warn: false
  alias Donuts.Repo

  alias Donuts.Sessions.Session

  def get_all() do
    Repo.all(Session)
  end

  def check_active(token) do
    Repo.all(Session)
    |> Enum.each(fn x ->
      Bcrypt.verify_pass(token, x)
    end) |> IO.inspect
  end

  def create_session(attrs) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end
end
