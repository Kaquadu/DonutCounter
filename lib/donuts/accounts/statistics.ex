defmodule Donuts.Accounts.Statistics do
  alias Donuts.Accounts
  alias Donuts.Accounts.User

  def get_statistics() do
    Accounts.get_all()
    |> Enum.reduce([], fn user, stats_list ->
      user_id = user |> Map.get(:id)
      user_name = user |> Map.get(:name)
      total_donuts = Donuts.Donuts.get_all_donuts_by_id(user_id) |> length()
      delivered_donuts = Donuts.Donuts.get_delivered_donuts_by_id(user_id) |> length()
      expired_donuts = Donuts.Donuts.get_expired_donuts_by_id(user_id) |> length()
      active_donuts = Donuts.Donuts.get_active_donuts_by_id(user_id) |> length()

      user_stats =
        %{}
        |> Map.put(:username, user_name)
        |> Map.put(:total_donuts, total_donuts)
        |> Map.put(:delivered_donuts, delivered_donuts)
        |> Map.put(:expired_donuts, expired_donuts)
        |> Map.put(:active_donuts, active_donuts)

      stats_list = [user_stats | stats_list]
    end)
  end
end
