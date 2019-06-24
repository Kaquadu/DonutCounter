defmodule Donuts.Background.ExpirationChecker do
  use GenServer
  alias Donuts.RoundPies.SlackCommunicator
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
        expired_donuts = Donuts.RoundPies.get_expired_donuts()
        communicate_expired_donuts(expired_donuts)
        schedule(@minutes * 60 * 1000)
        {:noreply, state}
    end
  end

  def communicate_expired_donuts([]), do: :ok

  def communicate_expired_donuts(expired_donuts) do
    mess =
      Enum.reduce(expired_donuts, "Expired donuts: \n", fn donut, message ->
        message = "#{message} Guilty: #{donut.guilty} | "
        message = "#{message} Sender: #{donut.sender} | "

        exp_date =
          donut.expiration_date
          |> DateTime.to_date()
          |> Date.to_string()

        message = "#{message} Expiration date: #{exp_date} | "
        message = "#{message} ID: #{donut.id} \n"
      end)
      |> URI.encode()

    SlackCommunicator.send_message_to_channel("general", mess)
  end

  def schedule(time) do
    Process.send_after(self(), :check_donuts, time)
  end
end
