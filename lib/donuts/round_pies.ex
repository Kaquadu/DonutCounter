defmodule Donuts.RoundPies do
  import Ecto.Query, warn: false
  alias Donuts.Repo
  alias Donuts.RoundPies.Donut
  alias Donuts.Accounts
  alias Donuts.Sessions.Session
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

  defdelegate handle_slack_event(event), to: Donuts.Slack.CommandsHandler

  def get_all() do
    Repo.all(Donut)
  end

  def get_by_id(id) do
    Repo.get(Donut, id)
  end

  def create_donut(attrs) do
    %Donut{}
    |> Donut.changeset(attrs)
    |> Repo.insert()
  end

  def add_new_donut(sender_name, target_name, target_id) do
    %{
      sender: sender_name,
      guilty: target_name,
      user_id: target_id,
      expiration_date:
        DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
      delivered: false
    }
    |> create_donut()
  end

  def delete_donut(%Donut{} = donut) do
    Repo.delete(donut)
  end

  def count_all_donuts(id) do
    Repo.all(
      from(d in Donut,
        where: d.user_id == ^id
      )
    )
    |> length()
  end

  def count_delivered_donuts(id) do
    Repo.all(
      from(d in Donut,
        where: d.user_id == ^id,
        where: d.delivered == true
      )
    )
    |> length()
  end

  def get_delivered_donuts(id) do
    Repo.all(
      from(d in Donut,
        where: d.user_id == ^id,
        where: d.delivered == true
      )
    )
  end

  def count_expired_donuts(id) do
    Repo.all(
      from(d in Donut,
        where: d.user_id == ^id,
        where: d.delivered == false,
        where: d.expiration_date < ^DateTime.utc_now()
      )
    )
    |> length()
  end

  def get_expired_donuts(id) do
    Repo.all(
      from(d in Donut,
        where: d.user_id == ^id,
        where: d.delivered == false,
        where: d.expiration_date < ^DateTime.utc_now()
      )
    )
  end

  def count_active_donuts(id) do
    Repo.all(
      from(d in Donut,
        where: d.user_id == ^id,
        where: d.delivered == false,
        where: d.expiration_date > ^DateTime.utc_now()
      )
    )
    |> length()
  end

  def get_active_donuts(id) do
    Repo.all(
      from(d in Donut,
        where: d.user_id == ^id,
        where: d.delivered == false,
        where: d.expiration_date > ^DateTime.utc_now()
      )
    )
  end

  def get_expired_donuts() do
    Repo.all(
      from(d in Donut,
        where: d.expiration_date < ^DateTime.utc_now(),
        where: d.delivered == false
      )
    )
  end

  def update_donut(%Donut{} = donut, attrs) do
    donut
    |> Donut.changeset(attrs)
    |> Repo.update()
  end
end
