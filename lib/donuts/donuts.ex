defmodule Donuts.Donuts do
  import Ecto.Query, warn: false
  alias Donuts.Repo
  alias Donuts.Donuts.Donut
  alias Donuts.Accounts

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

  def add_new_donut(conn, sender_name) do
    if Accounts.get_by_real_name(sender_name) do
      target_name = Session.get_current_user_name(conn)
      target_id = Accounts.get_by_real_name(target_name) |> Map.get(:id)

      %{:sender => sender_name,
        :guilty => target_name,
        :user_id => target_id,
        :expiration_date => DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
        :delivered => false}
      |> create_donut()
    end
    :ok
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
