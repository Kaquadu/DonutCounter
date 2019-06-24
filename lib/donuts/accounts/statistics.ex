defmodule Donuts.Accounts.Statistics do
  alias Donuts.Accounts
  alias Donuts.Accounts.User
  alias Donuts.RoundPies

  def get_statistics() do
    Accounts.get_all()
    |> Enum.reduce([], fn user, stats_list ->
      user_stats = %{
        :username => user.name,
        :total_donuts => RoundPies.get_all_donuts_by_id(user.id) |> length(),
        :delivered_donuts => RoundPies.get_delivered_donuts_by_id(user.id) |> length(),
        :expired_donuts => RoundPies.get_expired_donuts_by_id(user.id) |> length(),
        :active_donuts => RoundPies.get_active_donuts_by_id(user.id) |> length()
      }
      stats_list = [user_stats | stats_list]
    end)
  end
end
