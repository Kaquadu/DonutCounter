defmodule Donuts.SlackCommunicatorTests do
  use Donuts.DataCase
  alias Donuts.Donuts.SlackCommunicator

  test "add invalid donut / nil nil" do
    fname = nil
    lname = nil
    result = SlackCommunicator.process_add_donut(fname, lname, "USLACKBOT")
      |> Map.get("message") |> Map.get("text")
    expected_result = "Oops! There is no such person!"
    assert result = expected_result
  end

  # test "add invalid donut via fname & lname" do
  #   result = SlackCommunicator.process_add_donut("Kuba", "Kowalczykowski", "USLACKBOT")
  #   assert result = {:noreply, nil}
  # end
end
