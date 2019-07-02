defmodule Donuts.Slack.CommandsHandlerUnitTest do
  use Donuts.DataCase
  alias Donuts.Slack.CommandsHandler
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

  describe "Functions necessary to release a donut " do
    test "initialize_release valid target, with donuts" do
      {s, user1} =
        add_test_user(
          "UJY1A1VLM",
          "kkowalczykowski",
          "Kuba Kowalczykowski",
          true
        )

      {s, user2} =
        add_test_user(
          "CJY2B1VLM",
          "jkowalski",
          "Jan Kowalski",
          true
        )

      donut = add_test_donut(user1, user2)
      result = CommandsHandler.initialize_release(user2, user1.slack_id, "general")

      message =
        "Donuts delivered - confirmed by <@#{user1.slack_id}>! Thanks <@#{user2.slack_name}>!"
        |> URI.encode()

      assert result == {:ok, "donuts", user1.slack_id, message, "general"}
    end

    test "initialize_release valid target, w/o donuts" do
      {s, user1} =
        add_test_user(
          "UJY1A1VLM",
          "kkowalczykowski",
          "Kuba Kowalczykowski",
          true
        )

      {s, user2} =
        add_test_user(
          "CJY2B1VLM",
          "jkowalski",
          "Jan Kowalski",
          true
        )

      result = CommandsHandler.initialize_release(user2, user1.slack_id, "general")
      message = "<@#{user2.slack_name}> has no donut debts!" |> URI.encode()
      assert result == {:error, "donuts", user1.slack_id, message, "general"}
    end

    test "initialize_release invalid target" do
      {s, user1} =
        add_test_user(
          "UJY1A1VLM",
          "kkowalczykowski",
          "Kuba Kowalczykowski",
          true
        )

      result = CommandsHandler.initialize_release(nil, user1.slack_id, "general")
      message = "Wrong name of release target." |> URI.encode()

      assert result == {:error, "donuts", user1.slack_id, message, "general"}
    end

    test "release_donut valid" do
      {s, user1} =
        add_test_user(
          "UJY1A1VLM",
          "kkowalczykowski",
          "Kuba Kowalczykowski",
          true
        )

      {s, user2} =
        add_test_user(
          "CJY2B1VLM",
          "jkowalski",
          "Jan Kowalski",
          true
        )

      donut = add_test_donut(user1, user2)
      result = CommandsHandler.release_donut(false, user2, user1.slack_id, "general")

      message =
        "Donuts delivered - confirmed by <@#{user1.slack_id}>! Thanks <@#{user2.slack_name}>!"
        |> URI.encode()

      assert result == {:ok, "donuts", user1.slack_id, message, "general"}
    end

    test "release_donut self sending" do
      {s, user1} =
        add_test_user(
          "UJY1A1VLM",
          "kkowalczykowski",
          "Kuba Kowalczykowski",
          true
        )

      {s, user2} =
        add_test_user(
          "CJY2B1VLM",
          "jkowalski",
          "Jan Kowalski",
          true
        )

      donut = add_test_donut(user1, user2)
      result = CommandsHandler.release_donut(true, user1, user1.slack_id, "general")
      message = "Self release is forbidden ;)" |> URI.encode()

      assert result == {:error, "donuts", user1.slack_id, message, "general"}
    end

    test "save_release valid" do
      {s, user1} =
        add_test_user(
          "UJY1A1VLM",
          "kkowalczykowski",
          "Kuba Kowalczykowski",
          true
        )

      {s, user2} =
        add_test_user(
          "CJY2B1VLM",
          "jkowalski",
          "Jan Kowalski",
          true
        )

      {s, donut} = add_test_donut(user1, user2)
      result = CommandsHandler.save_release(donut, user2, user1.slack_id, "general")

      message =
        "Donuts delivered - confirmed by <@#{user1.slack_id}>! Thanks <@#{user2.slack_name}>!"
        |> URI.encode()

      assert result == {:ok, "donuts", user1.slack_id, message, "general"}
    end

    test "save_release no-debts" do
      {s, user1} =
        add_test_user(
          "UJY1A1VLM",
          "kkowalczykowski",
          "Kuba Kowalczykowski",
          true
        )

      {s, user2} =
        add_test_user(
          "CJY2B1VLM",
          "jkowalski",
          "Jan Kowalski",
          true
        )

      result = CommandsHandler.save_release(nil, user2, user1.slack_id, "general")
      message = message = "<@#{user2.slack_name}> has no donut debts!" |> URI.encode()

      assert result == {:error, "donuts", user1.slack_id, message, "general"}
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
