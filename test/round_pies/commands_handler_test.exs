defmodule Donuts.Slack.CommandsHandlerTest do
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

    test "/donuts @Kuba Kowalczykowski asdf" do
      add_test_user()

      result =
        %{
          "command" => "/donuts",
          "text" => "@kkowalczykowski asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
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

    test "/donuts @xyz asdf" do
      add_test_user()

      result =
        %{
          "command" => "/donuts",
          "text" => "@xyz asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end
  end

  describe "Releasing donut" do
    test "/donuts release @Kuba Kowalczykowski" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "release @kkowalczykowski",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts release @Kuba Kowalczykowski asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "release @kkowalczykowski asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end

    test "/donuts release @xyz" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "release @xyz",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts release @xyz asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "release @xyz asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end
  end

  describe "Removing donut" do
    test "/donuts remove @Kuba Kowalczykowski" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "remove @kkowalczykowski",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts remove @Kuba Kowalczykowski asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "remove @kkowalczykowski asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end

    test "/donuts remove @xyz" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "remove @xyz",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts remove @xyz asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "remove @xyz asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end
  end

  describe "Add days" do
    test "/donuts add_days @Kuba Kowalczykowski 1" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days @kkowalczykowski 1",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts add_days @Kuba Kowalczykowski 1 asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days @kkowalczykowski 1 asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()

      assert result == :unhandled
    end

    test "/donuts add_days @Kuba Kowalczykowski asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days @kkowalczykowski asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts add_days @asdf 1" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days @asdf 1",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts add_days @asdf asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days @asdf asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts add_days @Kuba Kowalczykowski" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days @kkowalczykowski",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts add_days @asdf" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days @asdf",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts add_days 1" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days 1",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end

    test "/donuts add_days" do
      {s, usr} = add_test_user()
      add_test_donut(usr)

      result =
        %{
          "command" => "/donuts",
          "text" => "add_days",
          "user_id" => "UJY1A1VLM",
          "channel_id" => "general"
        }
        |> CommandsHandler.handle_slack_command()
        |> Map.get("ok")

      assert result == true
    end
  end

  describe "Other functions" do
    test "get_active_donuts()" do
      {s, usr} = add_test_user()
      add_test_donut(usr)
      result = CommandsHandler.get_active_donuts()

      expected =
        "*Active donuts:* \n :doughnut: Donut: \n\n> Guilty: #{usr.name} \n\n> Sender: #{usr.name} \n\n> Expiration date: #{
          Date.utc_today()
        } \n"

      assert result == expected
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
