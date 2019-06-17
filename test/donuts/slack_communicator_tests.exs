defmodule Donuts.SlackCommunicatorTests do
  use Donuts.DataCase
  alias Donuts.Donuts.SlackCommunicator
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)

  test "add donut via fname & lname" do
    result = SlackCommunicator.process_add_donut("Kuba", "Kowalczykowski", "USLACKBOT")
    assert result = {:noreply, nil}
  end
end
