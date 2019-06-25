defmodule Donuts.Accounts do
  import Ecto.Query, warn: false
  alias Donuts.Repo
  alias Donuts.Accounts.User
  alias Donuts.RoundPies

  def get_all() do
    Repo.all(User)
  end

  def get_by_id(id) do
    Repo.get_by(User, id: id)
  end

  def get_by_slack_id(slack_id) do
    Repo.get_by(User, slack_id: slack_id)
  end

  def get_by_real_name(real_name) do
    Repo.get_by(User, name: real_name)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_statistics() do
    get_all()
    |> Enum.reduce([], fn user, stats_list ->
      user_stats = %{
        :username => user.name,
        :total_donuts => RoundPies.get_all_donuts_number(user.id),
        :delivered_donuts => RoundPies.get_delivered_donuts_number(user.id),
        :expired_donuts => RoundPies.get_expired_donuts_number(user.id),
        :active_donuts => RoundPies.get_active_donuts_number(user.id)
      }

      stats_list = [user_stats | stats_list]
    end)
  end
end
