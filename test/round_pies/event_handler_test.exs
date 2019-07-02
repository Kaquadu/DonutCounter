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

        test "user_change" do
            add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            result = 
                user_change_event()
                |> EventHandler.handle_slack_event()

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

    def user_change_event() do
        %{
            "type" => "user_change",
            "user" => %{
                "id" => "ABCDEFGH",
                "name" => "kkowalczykowski",
                "is_admin" => true,
                "profile" => %{
                    "real_name" => "K Kowalczykowski",
                    "country" => "Poland"
                }
            }
        }
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
end