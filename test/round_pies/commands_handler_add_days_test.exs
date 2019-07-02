defmodule Donuts.Slack.CommandsHandlerUnitTest do
  use Donuts.DataCase
  alias Donuts.Slack.CommandsHandler
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

  describe "Functions necessary to add days to a donut" do
    test "process_slack_command /donuts add_days @jkowalski 1" do
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
      {s, donut} = add_test_donut(user1, user2)
      result = CommandsHandler.process_slack_command(
        "/donuts",
        ["add_days", "@jkowalski", "1"],
        "UJY1A1VLM",
        "general"
      )

      message =
        "Oldest donuts of <@#{user2.slack_name}> updated by <@#{user1.slack_id}> - added 1 days!"
        |> URI.encode()

      assert result == {:ok, "donuts", user1.slack_name, message, "general"}
    end

    test "process_slack_command /donuts add_days @jkowalski -1" do
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
      {s, donut} = add_test_donut(user1, user2)
      result = CommandsHandler.process_slack_command(
        "/donuts",
        ["add_days", "@jkowalski", "1"],
        "UJY1A1VLM",
        "general"
      )

      message =
        "Oldest donuts of <@#{user2.slack_name}> updated by <@#{user1.slack_id}> - added -1 days!"
        |> URI.encode()

      assert result == {:ok, "donuts", user1.slack_name, message, "general"}
    end

    test "process_slack_command /donuts add_days" do
      result = CommandsHandler.process_slack_command(
        "/donuts",
        ["add_days"],
        "UJY1A1VLM",
        "general"
      )
      message = "Correct command: /dontus add_days _@username_ _days_." |> URI.encode()
      assert result == {:error, "donuts", "UJY1A1VLM", message, "general"}
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