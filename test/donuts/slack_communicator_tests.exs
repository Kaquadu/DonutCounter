defmodule Donuts.SlackCommunicatorTests do
  use Donuts.DataCase
  alias Donuts.Donuts.SlackCommunicator

  test "add valid donut via fname & lname" do
    result = SlackCommunicator.process_add_donut("Kuba", "Kowalczykowski", "USLACKBOT")
    assert result = {:noreply, nil}
  end
end
