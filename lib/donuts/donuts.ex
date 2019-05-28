defmodule Donuts.Donuts do
  import Ecto.Query, warn: false
  alias Donuts.Repo
  alias Donuts.Donuts.Donut

  def get_all() do
    Repo.all(Donut)
  end

  def create_donut(attrs) do
    %Donut{}
    |> Donut.changeset(attrs)
    |> Repo.insert
  end
end
