defmodule Donuts.SlackCommunicatorTests do
  use Donuts.DataCase
  alias Donuts.Donuts.SlackCommunicator
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

  describe "Testing info & help" do
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
  end

  describe "Testing donuts_add:" do
    test "valid via @" do
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

    test "valid via real name" do
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

    test "invalid via @" do
      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add", "MAMYBUGA"],
          "UJZAC1VLM",
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Oops! There is no such person!"
    end

    test "invalid via real name" do
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

    test "invalid more params" do
      {status, user} = add_test_user()
      user_slack_id = user |> Map.get(:slack_id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add", "Kuba", "Kowalczykowski", "NextParam"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Wrong name format!"
    end

    test "invalid no params" do
      {status, user} = add_test_user()
      user_slack_id = user |> Map.get(:slack_id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Wrong name format!"
    end
  end

  describe "Testing donuts_rm:" do
    test "valid donut id" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_name = user |> Map.get(:name)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(["donuts_rm", donut_id], user_slack_id, "donuts")
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Deleted donut debt of #{user_name}!"
    end

    test "invalid donut id" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_name = user |> Map.get(:name)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)
      fake_id = "487e9bfa-1111-1111-1111-b07c6994babe"

      result =
        SlackCommunicator.process_donut_command(["donuts_rm", fake_id], user_slack_id, "donuts")
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Oops! Wrong ID of the donut!"
    end

    test "no. params != 1" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_name = user |> Map.get(:name)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(["donuts_rm"], user_slack_id, "donuts")
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Wrong command format!"
    end
  end

  describe "Testing donuts_release:" do
    test "valid donut id" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_release", donut_id],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Released successfully!"
    end

    test "invalid donut id" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)
      fake_id = "487e9bfa-1111-1111-1111-b07c6994babe"

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_release", fake_id],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Oops! Wrong ID of the donut!"
    end

    test "no. params != 1" do
      {status, user} = add_test_user()
      user_slack_id = user |> Map.get(:slack_id)

      result =
        SlackCommunicator.process_donut_command(["donuts_release"], user_slack_id, "donuts")
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Wrong command format!"
    end
  end

  describe "Testing donuts_add_days" do
    test "valid id & valid days" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add_days", donut_id, "1"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Changed date!"
    end

    test "invalid id & valid days" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)
      fake_id = "487e9bfa-1111-1111-1111-b07c6994babe"

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add_days", fake_id, "1"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Oops! Wrong format of the command!"
    end

    test "invalid id & invalid days" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)
      fake_id = "487e9bfa-1111-1111-1111-b07c6994babe"

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add_days", fake_id, "abc"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Oops! Wrong format of the command! Days must be a number!"
    end

    test "valid id & invalid days" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add_days", donut_id, "abc"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Oops! Wrong format of the command! Days must be a number!"
    end

    test "no params != 2" do
      {status, user} = add_test_user()
      user_id = user |> Map.get(:id)
      user_slack_id = user |> Map.get(:slack_id)
      {status, donut} = add_test_donut(user_id)
      donut_id = donut |> Map.get(:id)

      result =
        SlackCommunicator.process_donut_command(
          ["donuts_add_days", donut_id, "1", "random_param"],
          user_slack_id,
          "donuts"
        )
        |> Map.get("message")
        |> Map.get("text")

      assert result == "Wrong command format!"
    end
  end

  describe "Other tests:" do
    test "random text" do
      result =
        SlackCommunicator.process_donut_command(
          ["randomcmd", "MAMYBUGA"],
          "UJZAC1VLM",
          "donuts"
        )

      assert result == {:ok, "UJZAC1VLM"}
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
