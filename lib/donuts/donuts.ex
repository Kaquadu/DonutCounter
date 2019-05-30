defmodule Donuts.Donuts do
  import Ecto.Query, warn: false
  alias Donuts.Repo
  alias Donuts.Donuts.Donut

  defdelegate handle_slack_event(event), to:
    Donuts.Donuts.SlackCommunicator

  def get_all() do
    Repo.all(Donut)
  end

  def get_by_id(id) do
    Repo.get(Donut, id)
  end

  def create_donut(attrs) do
    %Donut{}
    |> Donut.changeset(attrs)
    |> Repo.insert
  end

  def delete_donut(%Donut{} = donut) do
    Repo.delete(donut)
  end

  def update_donut(%Donut{} = donut, attrs) do
    donut
    |> Donut.changeset(attrs)
    |> Repo.update()
  end
end
