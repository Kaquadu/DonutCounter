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

  def get_by_slack_name(slack_name) do
    Repo.get_by(User, slack_name: slack_name)
  end

  def get_by_real_name(real_name) do
    Repo.get_by(User, name: real_name)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def get_statistics() do
    get_all()
    |> Enum.reduce([], fn user, stats_list ->
      user_stats = %{
        :username => user.name,
        :slack_name => user.slack_name,
        :total_donuts => RoundPies.count_all_donuts(user.id),
        :delivered_donuts => RoundPies.count_delivered_donuts(user.id),
        :expired_donuts => RoundPies.count_expired_donuts(user.id),
        :active_donuts => RoundPies.count_active_donuts(user.id)
      }

      stats_list = [user_stats | stats_list]
    end)
  end
end
