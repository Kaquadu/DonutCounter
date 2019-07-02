defmodule Donuts.Slack.CommandsHandler do
  @oauth_token Application.get_env(:donuts, :oauth_token)
  @donuts_channel Application.get_env(:donuts, :donuts_channel_id)
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  @client_id Application.get_env(:donuts, :client_id)
  @client_secret Application.get_env(:donuts, :client_secret)

  alias Donuts.Accounts
  alias Donuts.RoundPies.Donut
  alias Donuts.RoundPies
  alias Donuts.Helpers.HTTPHelper
  alias Donuts.Slack.Operations

  defguard not_other_command(value)
           when value != "list" and value != "release" and value != "remove" and
                  value != "add_days"

  def handle_slack_command(%{
        "command" => command,
        "text" => params,
        "user_id" => sender_id,
        "channel_id" => channel_id
      }) do
    cmd_params = params |> String.split(" ", trim: true)
    process_slack_command(command, cmd_params, sender_id, channel_id)
  end

  def handle_slack_command(_params), do: :unhandled

  def process_slack_command("/donuts", ["list" | params], from_id, channel_id)
      when params == [] do
    message = get_active_donuts() |> URI.encode()
    {:info, "donuts", from_id, message, channel_id} |> Operations.message()
  end

  def process_slack_command("/donuts", ["release", target_name | params], from_id, channel_id)
      when params == [] do
    target_name = target_name |> String.trim("@")
    target = Accounts.get_by_slack_name(target_name)
    initialize_release(target, from_id, channel_id)
    |> Operations.message()
  end

  def process_slack_command("/donuts", ["release" | params], from_id, channel_id)
      when params == [] do
    message = "Correct command: /donuts release _@username_." |> URI.encode()
    {:info, "donuts", from_id, message, channel_id} |> Operations.message()
  end

  def process_slack_command("/donuts", ["remove", target_name | params], from_id, channel_id)
      when params == [] do
    target_name = target_name |> String.trim("@")
    target = Accounts.get_by_slack_name(target_name)
    initialize_remove(target, from_id, channel_id)
    |> Operations.message()
  end

  def process_slack_command("/donuts", ["remove" | params], from_id, channel_id)
      when params == [] do
    message = "Correct command: /donuts remove _@username_." |> URI.encode()
    {:info, "donuts", from_id, message, channel_id} |> Operations.message()
  end

  def process_slack_command("/donuts", ["help" | params], from_id, channel_id)
      when params == [] do
    message =
      ":doughnut: *Welcome to donut counter!* :doughnut: \n
    List of commands:
    *donuts your-name* - add donut debt to the currently logged person. Remember to sign yourself - we all would like to know who is the cause of delicious donuts :wink:
    *donuts release name-of-guilty* - releases the odlest guilty's debt marking it as delivered
    *donuts remove name-of-guilty* - removes the newest guilty's debt and removes it from statistics, used in case of mistakes
    *donuts help* - displays list of commands
    *donuts list* - display list of currently active donuts \n
    On the webapp you can sign in and check statistic. Good luck and don't forget to secure yourself :wink:"
      |> URI.encode()

    {:info, "donuts", from_id, message, channel_id} |> Operations.message()
  end

  def process_slack_command(
        "/donuts",
        ["add_days", target_name, days | params],
        from_id,
        channel_id
      )
      when params == [] do
    days = days |> Integer.parse()
    target_name = target_name |> String.trim("@")
    target = Accounts.get_by_slack_name(target_name)
    initialize_add_days(target, days, from_id, channel_id)
    |> Operations.message()
  end

  def process_slack_command("/donuts", ["add_days", param | params], from_id, channel_id)
      when params == [] do
    message =
      "Wrong function arity. Correct command: /dontus add_days _@username_ _days_."
      |> URI.encode()

    {:error, "donuts", from_id, message, channel_id} |> Operations.message()
  end

  def process_slack_command("/donuts", ["add_days" | params], from_id, channel_id)
      when params == [] do
    message = "Correct command: /dontus add_days _@username_ _days_." |> URI.encode()
    {:error, "donuts", from_id, message, channel_id} |> Operations.message()
  end

  def process_slack_command("/donuts", [name | params], from_id, channel_id)
      when params == [] and name != nil and not_other_command(name) do
    process_adding_donut(name, from_id, channel_id)
    |> Operations.message()
  end

  def process_slack_command("/donuts", params, from_id, channel_id), do: :unhandled

  def process_adding_donut(sender_name, target_id, channel_id) do
    sender_name = sender_name |> String.trim("@")
    sender = Accounts.get_by_slack_name(sender_name)
    initialize_donut(sender, target_id, channel_id)
  end

  def check_self_sending(sender, receiver), do: sender == receiver

  def initialize_donut(sender, target_id, channel_id) when sender == [] or sender == nil do
    message = "I'm sorry, it seems you picked a wrong username :(" |> URI.encode()
    {:error, "donuts", target_id, message, channel_id}
  end

  def initialize_donut(sender, target_id, channel_id) do
    guilty = Accounts.get_by_slack_id(target_id)

    check_self_sending(guilty.name, sender.name)
    |> add_donut(guilty, sender, channel_id)
  end

  def initialize_release(target, from_id, channel_id) when target == [] or target == nil do
    message = "Wrong name of release target." |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def initialize_release(target, from_id, channel_id) do
    check_self_sending(target.slack_id, from_id)
    |> release_donut(target, from_id, channel_id)
  end

  def initialize_remove(target, from_id, channel_id) when target == [] or target == nil do
    message = "Wrong name of remove target." |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def initialize_remove(target, from_id, channel_id) do
    check_self_sending(target.slack_id, from_id)
    |> remove_donut(target, from_id, channel_id)
  end

  def initialize_add_days(nil, days, from_id, channel_id) do
    message = "There is no such person." |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def initialize_add_days(target, days, from_id, channel_id) do
    check_self_sending(target.slack_id, from_id)
    |> add_days(target, days, from_id, channel_id)
  end

  def add_donut(false, guilty, sender, channel_id) do
    %{
      sender: sender.name,
      guilty: guilty.name,
      user_id: guilty.id,
      expiration_date: DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
      delivered: false
    }
    |> RoundPies.create_donut()

    message =
      "Mmmmm... <@#{guilty.slack_name}> just owes us some donuts thanks to <@#{sender.slack_name}>'s vigilance"
      |> URI.encode()

    {:ok, "donuts", guilty.slack_name, message, channel_id}
  end

  def add_donut(true, guilty, sender, channel_id) do
    message = "Self sending is forbidden. Do you wanna owe donuts to everyone..?" |> URI.encode()
    {:error, "donuts", guilty.slack_name, message, channel_id}
  end

  def release_donut(false, target, from_id, channel_id) do
    release_target =
      target.id
      |> RoundPies.get_oldest_active_donut()
      |> save_release(target, from_id, channel_id)
  end

  def release_donut(true, target, from_id, channel_id) do
    message = "Self release is forbidden ;)" |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def save_release(nil, target, from_id, channel_id) do
    message = "<@#{target.slack_name}> has no donut debts!" |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def save_release(release_target, target, from_id, channel_id) do
    case RoundPies.update_donut(release_target, %{:delivered => true}) do
      {:ok, donut} ->
        message =
          "Donuts delivered - confirmed by <@#{from_id}>! Thanks <@#{target.slack_name}>!"
          |> URI.encode()

        {:ok, "donuts", from_id, message, channel_id}

      {:error, %Ecto.Changeset{} = changeset} ->
        message = "Oops! Error in changeset!" |> URI.encode()
        {:error, "donuts", from_id, message, channel_id}
    end
  end

  def remove_donut(false, target, from_id, channel_id) do
    remove_target =
      target.id
      |> RoundPies.get_newest_active_donut()
      |> save_remove(target, from_id, channel_id)
  end

  def remove_donut(true, target, from_id, channel_id) do
    message = "Self remove is forbidden ;)" |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def save_remove(nil, target, from_id, channel_id) do
    message = "<@#{target.slack_name}> has no donut debts!" |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def save_remove(remove_target, target, from_id, channel_id) do
    RoundPies.delete_donut(remove_target)
    message = "Newest donut of <@#{target.slack_name}> removed." |> URI.encode()
    {:ok, "donuts", from_id, message, channel_id}
  end

  def add_days(selfsending, target, :error, from_id, channel_id) do
    message = "Parameter 'days' mus be a number." |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def add_days(true, target, days, from_id, channel_id) do
    message = "Adding days to your debts by yourself is forbidden ;)" |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def add_days(false, target, days, from_id, channel_id) do
    donut =
      target.id
      |> RoundPies.get_oldest_active_donut()
      |> save_add_days(target, days, from_id, channel_id)
  end

  def save_add_days(nil, target, days, from_id, channel_id) do
    message = "<@#{target.slack_name}> has no donut debts!" |> URI.encode()
    {:error, "donuts", from_id, message, channel_id}
  end

  def save_add_days(donut, target, days, from_id, channel_id) do
    new_expiration_date = DateTime.add(donut.expiration_date, days * 24 * 60 * 60, :second)
    RoundPies.update_donut(donut, %{:expiration_date => new_expiration_date})

    message =
      "Oldest donuts of <@#{target.slack_name}> updated by <@#{from_id}> - added #{days} days!"
      |> URI.encode()

    {:ok, "donuts", from_id, message, channel_id}
  end

  def get_active_donuts() do
    active_donuts =
      RoundPies.get_all()
      |> Enum.reduce("*Active donuts:* \n", fn donut, message ->
        donut
        delivered = donut.delivered

        if delivered == false do
          message = "#{message} :doughnut: Donut: \n"
          message = "#{message}\n> Guilty: #{donut.guilty} \n"
          message = "#{message}\n> Sender: #{donut.sender} \n"

          exp_date =
            donut.expiration_date
            |> DateTime.to_date()
            |> Date.to_string()

          message = "#{message}\n> Expiration date: #{exp_date} \n"
        else
          message
        end
      end)
  end
end
