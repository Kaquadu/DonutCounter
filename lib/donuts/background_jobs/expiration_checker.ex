defmodule Donuts.Background.ExpirationChecker do
  use GenServer
  alias Donuts.Donuts.SlackCommunicator
  @minutes Application.get_env(:donuts, :donuts_checker_minutes)

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    # Schedule work to be performed on start
    schedule(1)
    {:ok, state}
  end

  def handle_info(message, state) do
    case message do
      :check_donuts ->
        expired_donuts = Donuts.Donuts.get_expired_donuts()
        communicate_expired_donuts(expired_donuts)
        schedule(@minutes * 60 * 1000)
        {:noreply, state}
    end
  end

  def communicate_expired_donuts([]), do: :ok

  def communicate_expired_donuts(expired_donuts) do
    mess =
      Enum.reduce(expired_donuts, "Expired donuts: \n", fn donut, message ->
        message = "#{message} Guilty: #{Map.get(donut, :guilty)} | "
        message = "#{message} Sender: #{Map.get(donut, :sender)} | "

        exp_date =
          Map.get(donut, :expiration_date)
          |> DateTime.to_date()
          |> Date.to_string()

        message = "#{message} Expiration date: #{exp_date} | "
        message = "#{message} ID: #{Map.get(donut, :id)} \n"
      end)
      |> URI.encode()

    SlackCommunicator.send_message_to_channel("general", mess)
  end

  def schedule(time) do
    Process.send_after(self(), :check_donuts, time)
  end
end
