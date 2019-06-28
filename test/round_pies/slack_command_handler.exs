defmodule Donuts.SlackCommunicatorTests do
  use Donuts.DataCase
  alias Donuts.Slack.CommandsHandler
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

  describe "Help & list" do
    test "/donuts help" do
      result =
        %{
          "command" => "/donuts",
          "text" => "help",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts help asdf" do
      result =
        %{
          "command" => "/donuts",
          "text" => "help asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end

    test "/donuts list" do
      result =
        %{
          "command" => "/donuts",
          "text" => "list",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts list asdf" do
      result =
        %{
          "command" => "/donuts",
          "text" => "list asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end
  end

  describe "Adding donut" do
    test "/donuts @Kuba Kowalczykowski" do
      add_test_user()
      result =
        %{
          "command" => "/donuts",
          "text" => "@kkowalczykowski",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts @xyz" do
      add_test_user()
      result =
        %{
          "command" => "/donuts",
          "text" => "@xyz",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end
  end

  def add_test_user() do
    %{
      "slack_id" => "UJY1A1VLM",
      "slack_name" => "kkowalczykowski",
      "name" => "Kuba Kowalczykowski",
      "is_admin" => true
    }
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
