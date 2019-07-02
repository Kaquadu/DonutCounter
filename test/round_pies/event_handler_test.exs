defmodule Donuts.Slack.CommandsHandlerUnitTest do
    use Donuts.DataCase
    alias Donuts.Slack.EventHandler
    alias Donuts.Accounts.User

    describe "Join event" do
        test "team_join" do
            result = 
                team_join_event()
                |> EventHandler.handle_slack_event()
                |> Tuple.to_list()
                |> List.first()

            assert result == :ok
        end
    end


    #event mocks
    def team_join_event() do
        %{
            "type" => "team_join",
            "user" => %{
                "id" => "ABCDEFGH",
                "name" => "kkowalczykowski",
                "is_admin" => true,
                "profile" => %{
                    "real_name" => "Kuba Kowalczykowski",
                    "country" => "Poland"
                }
            }
        }
    end
end