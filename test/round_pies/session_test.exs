defmodule Donuts.Slack.CommandsHandlerUnitTest do
  use Donuts.DataCase
  alias Donuts.Sessions

  describe "Session tests" do
    test "auth_user valid, user not in database" do
      result =
        create_token_info(true)
        |> Sessions.auth_user()

      assert result == :ok
    end

    test "auth valid, user already in database" do
      add_test_user(
        "UJY1A1VLM",
        "kkowalczykowski",
        "Kuba Kowalczykowski",
        true
      )

      result =
        create_token_info(true)
        |> Sessions.auth_user()

      assert result == :ok
    end

    test "auth invalid - %{ok => false}" do
      result =
        create_token_info(false)
        |> Sessions.auth_user()

      assert result == :invalid_request
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

  def create_token_info(ok) do
    %{
      "ok" => ok,
      "access_token" => "asdfghjklqwertyuiop1234567890",
      "user" => %{
        "id" => "UJY1A1VLM",
        "name" => "Kuba Kowalczykowski"
      }
    }
  end
end
