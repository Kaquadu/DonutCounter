defmodule Donuts.Slack.CommandsHandlerUnitTest do
    use Donuts.DataCase
    alias Donuts.Slack.CommandsHandler

    describe "Functions necessary to add a donut" do
        test "process_adding_donut - valid data" do
            {s, user1} = add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            {s, user1} = add_test_user(
                "CJY2B1VLM",
                "jkowalski",
                "Jan Kowalski",
                true
            )
            result = 
                CommandsHandler.process_adding_donut(user1.slack_name, user2.slack_id, "general")

            assert result == {:ok, "donuts", user1.slack_name, message, channel_id}
        end
    end


    def add_test_user(id, s_name, name, i_a) do
        %{
          "slack_id" => id,
          "slack_name" => s_name,
          "name" => name,
          "is_admin" => i_a
        }
        |> Donuts.Accounts.create_user()
    end
    
    def add_test_donut(user) do
        %{
          :sender => user.name,
          :guilty => user.name,
          :user_id => user.id,
          :expiration_date =>
            DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
          :delivered => false
        }
        |> Donuts.RoundPies.create_donut()
    end
end