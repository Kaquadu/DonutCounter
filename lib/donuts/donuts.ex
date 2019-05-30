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

  def get_all_donuts_by_id(id) do
    Repo.all(from d in Donut,
            where: d.user_id == ^id)
  end

  def get_delivered_donuts_by_id(id) do
    Repo.all(from d in Donut,
            where: d.user_id == ^id,
            where: d.delivered == true)
  end

  def get_expired_donuts_by_id(id) do
    Repo.all(from d in Donut,
            where: d.user_id == ^id,
            where: d.delivered == false,
            where: d.expiration_date < ^DateTime.utc_now())
  end

  def get_active_donuts_by_id(id) do
    Repo.all(from d in Donut,
            where: d.user_id == ^id,
            where: d.delivered == false,
            where: d.expiration_date > ^DateTime.utc_now())
  end

  def get_expired_donuts() do
    Repo.all(from d in Donut,
            where: d.expiration_date < ^DateTime.utc_now(),
            where: d.delivered == false)
  end

  def update_donut(%Donut{} = donut, attrs) do
    donut
    |> Donut.changeset(attrs)
    |> Repo.update()
  end
end
