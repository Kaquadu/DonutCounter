defmodule Donuts.SlackCommunicatorTests do
  use Donuts.DataCase
  alias Donuts.Donuts.SlackCommunicator
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

  describe "Testing commands in general:" do
    test "info cmd" do
      result =
        SlackCommunicator.process_donut_command(["donuts_info"], "UJY1A1VLM", "donuts")
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Active donuts: \n"
    end

    test "halp cmd" do
      result =
        SlackCommunicator.process_donut_command(["donuts_help"], "UJY1A1VLM", "donuts")
        |> Map.get("ok")

      assert result == true
    end

    test "add cmd via slack @" do
      {status, user} = add_test_user()
      user_slack_id = user |> Map.get(:slack_id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add", user_slack_id],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Succesfuly added donut debt!"
    end

    test "add cmd via fname & lname" do
      {status, user} = add_test_user()
      user_slack_id = user |> Map.get(:slack_id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add", "Kuba", "Kowalczykowski"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Succesfuly added donut debt!"
    end

    test "rm cmd" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_name = user |> Map.get(:name)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(["donuts_rm", donut_id], user_id, "donuts")
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Deleted donut debt of #{user_name}!"
    end

    test "release cmd" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(["donuts_release", donut_id], user_id, "donuts")
        |> Map.get("ok")

      assert result == true
    end

    test "add cmd via fname & lname invalid" do
      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add", "ASDF", "XYZ"],
          "UJZAC1VLM",
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Oops! There is no such person!"
    end
  end

  def add_test_user() do
    %{"slack_id" => "UJY1A1VLM", "name" => "Kuba Kowalczykowski", "is_admin" => true}
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
    |> Donuts.Donuts.create_donut()
  end
end
