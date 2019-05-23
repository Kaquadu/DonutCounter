defmodule Donuts.Accounts do
  import Ecto.Query, warn: false
  alias Donuts.Repo

  alias Donuts.Accounts.User

  def get_all_users() do
    Repo.all(User)
  end

end
