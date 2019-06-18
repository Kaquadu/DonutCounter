defmodule Donuts.Accounts do
  import Ecto.Query, warn: false
  alias Donuts.Repo
  alias Donuts.Accounts.User

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
end
