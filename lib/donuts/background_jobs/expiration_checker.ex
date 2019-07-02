defmodule Donuts.Background.ExpirationChecker do
  use GenServer
  alias Donuts.Slack
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
    Enum.map(expired_donuts, fn donut ->
        exp_date =
          donut.expiration_date
          |> DateTime.to_date()
          |> Date.to_string()
        Enum.join([":doughnut: Donut: \n", "\n> Guilty: #{donut.guilty} \n", "\n> Sender: #{donut.sender} \n", "\n> Expiration date: #{exp_date} \n"])
      end)
      |> Enum.join()
      |> URI.encode()

    Slack.Operations.send_message_to_channel("general", mess)
  end

  def schedule(time) do
    Process.send_after(self(), :check_donuts, time)
  end
end
