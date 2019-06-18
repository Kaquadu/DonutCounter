defmodule Donuts.SlackCommunicatorTests do
  use Donuts.DataCase
  alias Donuts.Donuts.SlackCommunicator

  describe "Testing commands: " do
    test "help cmd" do
      result = SlackCommunicator.process_donut_command("donuts_info", "UJY1A1VLM", "donuts")
      assert result == {:noreply, nil}
    end
  end

  describe "Testing adding donuts: " do
    test "valid donut with fname and lname" do
      add_test_user()
      result = SlackCommunicator.process_add_donut("Kuba", "Kowalczykowski", "UJY1A1VLM")
        |> Map.get("message") |> Map.get("text")
      expected_result = "Succesfuly added donut debt!"
      assert result == expected_result
    end

    test "valid donut with slack id" do
      add_test_user()
      result = SlackCommunicator.process_add_donut("UJY1A1VLM", nil, "UJY1A1VLM")
        |> Map.get("message") |> Map.get("text")
      expected_result = "Succesfuly added donut debt!"
      assert result == expected_result
    end

    test "donut with invalid sender slack id" do
      result = SlackCommunicator.process_add_donut("UJY1A23LM", nil, "UJY1A1VLM")
        |> Map.get("message") |> Map.get("text")
      expected_result = "Oops! There is no such person!"
      assert result == expected_result
    end
  end

  describe "Testing rm donuts: " do
    test "rm valid donut" do

    end
  end

  def add_test_user() do
    %{"slack_id" => "UJY1A1VLM",
      "name" => "Kuba Kowalczykowski",
      "is_admin" => true}
      |> Donuts.Accounts.create_user()
  end

  def add_test_donut() do

  end
end
