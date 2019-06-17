defmodule Donuts.SlackCommunicatorTests do
  alias Donuts.Donuts.SlackCommunicator

  test "add donut via fname & lname" do
    result = SlackCommunicator.process_add_donut("Kuba", "Kowalczykowski", "USLACKBOT")
    assert result = {:noreply, nil}
  end
end
