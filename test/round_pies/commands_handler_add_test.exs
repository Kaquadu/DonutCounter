defmodule Donuts.Slack.CommandsHandlerUnitTest do
    use Donuts.DataCase
    alias Donuts.Slack.CommandsHandler
    @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

    describe "Functions necessary to add a donut" do
        test "process_adding_donut - valid data" do
            {s, user1} = add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            {s, user2} = add_test_user(
                "CJY2B1VLM",
                "jkowalski",
                "Jan Kowalski",
                true
            )
            result = 
                CommandsHandler.process_adding_donut(user1.slack_name, user2.slack_id, "general")

            expected_message = "Mmmmm... <@#{user2.slack_name}> just owes us some donuts thanks to <@#{user1.slack_name}>'s vigilance"
            |> URI.encode()

            assert result == {:ok, "donuts", user2.slack_name, expected_message, "general"}
        end

        test "process_adding_donut - self sending" do
            {s, user1} = add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            result = 
                CommandsHandler.process_adding_donut(user1.slack_name, user1.slack_id, "general")

            expected_message = message = "Self sending is forbidden. Do you wanna owe donuts to everyone..?" 
            |> URI.encode()

            assert result == {:error, "donuts", user1.slack_name, expected_message, "general"}
        end

        test "process_adding_donut - wrong username" do
            {s, user1} = add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            {s, user2} = add_test_user(
                "CJY2B1VLM",
                "jkowalski",
                "Jan Kowalski",
                true
            )
            result = 
                CommandsHandler.process_adding_donut("@asdf", user2.slack_id, "general")

            expected_message = message = "I'm sorry, it seems you picked a wrong username :(" 
            |> URI.encode()

            assert result == {:error, "donuts", user2.slack_id, expected_message, "general"}
        end

        test "initialize_donut - valid data" do
            {s, user1} = add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            {s, user2} = add_test_user(
                "CJY2B1VLM",
                "jkowalski",
                "Jan Kowalski",
                true
            )
            result = 
                CommandsHandler.initialize_donut(user1, user2.slack_id, "general")

            expected_message = "Mmmmm... <@#{user2.slack_name}> just owes us some donuts thanks to <@#{user1.slack_name}>'s vigilance"
            |> URI.encode()

            assert result == {:ok, "donuts", user2.slack_name, expected_message, "general"}
        end

        test "initialize_donut - sender invalid" do
            {s, user2} = add_test_user(
                "CJY2B1VLM",
                "jkowalski",
                "Jan Kowalski",
                true
            )
            result = 
                CommandsHandler.initialize_donut(nil, user2.slack_id, "general")

            expected_message = "I'm sorry, it seems you picked a wrong username :(" |> URI.encode()

            assert result == {:error, "donuts", user2.slack_id, expected_message, "general"}
        end

        test "add_donut - valid data" do
            {s, user1} = add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            {s, user2} = add_test_user(
                "CJY2B1VLM",
                "jkowalski",
                "Jan Kowalski",
                true
            )
            result = CommandsHandler.add_donut(false, user1, user2, "general")

            message = "Mmmmm... <@#{user1.slack_name}> just owes us some donuts thanks to <@#{user2.slack_name}>'s vigilance"
                |> URI.encode()

            assert result == {:ok, "donuts", user1.slack_name, message, "general"}
        end

        test "add_donut - self sending" do
            {s, user1} = add_test_user(
                "UJY1A1VLM",
                "kkowalczykowski",
                "Kuba Kowalczykowski",
                true
            )
            {s, user2} = add_test_user(
                "CJY2B1VLM",
                "jkowalski",
                "Jan Kowalski",
                true
            )
            result = CommandsHandler.add_donut(true, user1, user1, "general")

            message = "Self sending is forbidden. Do you wanna owe donuts to everyone..?" |> URI.encode()

            assert result == {:error, "donuts", user1.slack_name, message, "general"}
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