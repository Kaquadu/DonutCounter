defmodule Donuts.RoundPiesTests do
    use Donuts.DataCase
    alias Donuts.RoundPies
    alias Donuts.RoundPies.Donut

    describe "Testing data services" do
        test "add donut via web" do
            {status, user} = add_test_user()
            {status, donut} = RoundPies.add_new_donut(user[:name], user[:name], user[:id])
            assert status == :ok
        end
    end

    def add_test_user() do
        %{"slack_id" => "UJY1A1VLM", "name" => "Kuba Kowalczykowski", "is_admin" => true}
        |> Donuts.Accounts.create_user()
      end
    
      def add_test_donut(user_id) do
        %{
          :sender => "Kuba Kowalczykowski",
          :guilty => "Kuba Kowalczykowski",
          :user_id => user_id,
          :expiration_date =>
            DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
          :delivered => false
        }
        |> Donuts.RoundPies.create_donut()
      end
end