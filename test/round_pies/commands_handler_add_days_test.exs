defmodule Donuts.Slack.CommandsHandlerUnitTest do
    use Donuts.DataCase
    alias Donuts.Slack.CommandsHandler

    describe "Function necessary to add days to a donut" do
        test "process_slack_command" do

        end

        test "" do
          
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
    
    def add_test_donut(sender, guilty) do
        %{
          :sender => sender.name,
          :guilty => guilty.name,
          :user_id => guilty.id,
          :expiration_date =>
            DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
          :delivered => false
        }
        |> Donuts.RoundPies.create_donut()
    end
end