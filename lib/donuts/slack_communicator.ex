defmodule Donuts.SlackCommunicator do
  @oauth_token Application.get_env(:donuts, :oauth_token)
  @donuts_channel Application.get_env(:donuts, :donuts_channel_id)
  @expiration_days Application.get_env(:donuts, :donuts_expiration_days)
  alias Donuts.Accounts
  alias Donuts.RoundPies.Donut
  alias Donuts.RoundPies
  alias Donuts.Helpers.HTTPHelper

  # defguard is_add_via_slack(cmd_ingridients) when List.first(cmd_ingridients) == "donuts_add" and length(cmd_ingridients) == 2

  def get_all_users() do
    "https://slack.com/api/users.list?token=#{@oauth_token}&pretty=1"
    |> HTTPHelper.get_body()
  end

  def send_message_to_channel(channel, text) do
    "https://slack.com/api/chat.postMessage?token=#{@oauth_token}&channel=#{channel}&text=#{text}&as_user=false"
    |> HTTPHelper.get_body()
  end

  def handle_slack_event(%{
        "type" => event_type,
        "channel" => event_channel,
        "text" => event_text,
        "user" => user_id
      })
      when event_type == "message" do
    cmd_ingridients = event_text |> String.split(" ", trim: true)
    process_donut_command(cmd_ingridients, user_id, event_channel)
  end

  def handle_slack_event(_params) do
    {:unhandled_event, nil}
  end

  def process_donut_command(["donuts_add" | params], sender_id, event_channel)
      when length(params) == 0 do
    message = "Wrong name format!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_command(["donuts_add" | params], sender_id, event_channel)
      when length(params) == 1 do
    process_add_donut(params, nil, sender_id)
  end

  def process_donut_command(["donuts_add" | params], sender_id, event_channel)
      when length(params) == 2 do
    [cmd_fname, cmd_lname] = params
    process_add_donut(cmd_fname, cmd_lname, sender_id)
  end

  def process_donut_command(["donuts_add" | params], sender_id, event_channel)
      when length(params) > 2 do
    message = "Wrong name format!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_command(["donuts_rm" | params], sender_id, event_channel)
      when length(params) == 1 do
    [id] = params
    delete_target = Donuts.RoundPies.get_by_id(id)
    process_rm_donut(delete_target)
  end

  def process_donut_command(["donuts_rm" | params], sender_id, event_channel)
      when length(params) != 1 do
    message = "Wrong command format!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_command(["donuts_release" | params], sender_id, event_channel)
      when length(params) == 1 do
    [id] = params
      Donuts.RoundPies.get_by_id(id)
      |> check_self_release(sender_id)
      |> process_release_donut()
  end

  def process_donut_command(["donuts_release" | params], sender_id, event_channel)
      when length(params) != 1 do
    message = "Wrong command format!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_command(["donuts_add_days" | params], sender_id, event_channel)
      when length(params) == 2 do
    [id, days] = params
    donut_target = Donuts.RoundPies.get_by_id(id)

    try do
      int_days = String.to_integer(days)
      process_donut_add_days(donut_target, int_days)
    rescue
      ArgumentError ->
        message = "Oops! Wrong format of the command! Days must be a number!" |> URI.encode()
        send_message_to_channel(@donuts_channel, message)
    end
  end

  def process_donut_command(["donuts_add_days" | params], sender_id, event_channel)
      when length(params) != 2 do
    message = "Wrong command format!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_command(["donuts_info" | params], sender_id, event_channel) do
    active_donuts = get_active_donuts() |> process_donuts_info()
  end

  def process_donut_command(["donuts_help" | params], sender_id, event_channel) do
    send_help()
  end

  def process_donut_command(_, sender_id, event_channel) do
    {:ok, sender_id}
  end

  def process_add_donut([cmd_fname], cmd_lname, from_id) when cmd_lname == nil do
    get_sender(cmd_fname)
    |> check_selfsending(from_id)
    |> add_donut(from_id)
  end

  def process_add_donut(cmd_fname, cmd_lname, from_id) do
    cmd_sender_name = "#{cmd_fname} #{cmd_lname}"

    get_sender(cmd_sender_name)
    |> check_selfsending(from_id)
    |> add_donut(from_id)
  end

  def get_sender(sender_name) do
    sender_by_rn = Accounts.get_by_real_name(sender_name)

    sender_by_sid =
      sender_name
      |> String.trim("<")
      |> String.trim(">")
      |> String.trim("@")
      |> Accounts.get_by_slack_id()

    {sender_by_rn, sender_by_sid}
  end

  def check_selfsending({nil, nil}, _), do: {nil ,nil}

  def check_selfsending({nil, sender_by_sid}, target_id) do
    target_name = Accounts.get_by_slack_id(target_id) |> Map.get(:name)
    if (sender_by_sid.name == target_name) do
      {:self, :self}
    else
      {nil, sender_by_sid}
    end
  end

  def check_selfsending({sender_by_rn, nil}, target_id) do
    target_name = Accounts.get_by_slack_id(target_id) |> Map.get(:name)
    if (sender_by_rn.name == target_name) do
      {:self, :self}
    else
      {sender_by_rn, nil}
    end
  end


  def add_donut({nil, nil}, _) do
    message = "Oops! There is no such person!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def add_donut({:self, :self}, _) do
    message = "Self sending is forbidden!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def add_donut({nil, sender_by_sid}, target_id) do
    %{
      :sender => sender_by_sid.name,
      :guilty => Accounts.get_by_slack_id(target_id) |> Map.get(:name),
      :user_id => Accounts.get_by_slack_id(target_id) |> Map.get(:id),
      :expiration_date =>
        DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
      :delivered => false
    }
    |> RoundPies.create_donut()

    message = "Succesfuly added donut debt!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def add_donut({sender_by_rn, nil}, target_id) do
    %{
      :sender => sender_by_rn.name,
      :guilty => Accounts.get_by_slack_id(target_id) |> Map.get(:name),
      :user_id => Accounts.get_by_slack_id(target_id) |> Map.get(:id),
      :expiration_date =>
        DateTime.add(DateTime.utc_now(), @expiration_days * 24 * 60 * 60, :second),
      :delivered => false
    }
    |> RoundPies.create_donut()

    message = "Succesfuly added donut debt!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def add_donut({nil, nil}, target_id) do
    message = "Wrong user!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_rm_donut(nil) do
    message = "Oops! Wrong ID of the donut!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_rm_donut(delete_target) do
    RoundPies.delete_donut(delete_target)
    name = delete_target.guilty
    message = "Deleted donut debt of #{name}!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_release_donut(nil) do
    message = "Oops! Wrong ID of the donut!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_release_donut(:self) do
    message = "Self release is forbidden!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_release_donut(release_target) do
    case RoundPies.update_donut(release_target, %{:delivered => true}) do
      {:ok, donut} ->
        message = "Released successfully!" |> URI.encode()
        send_message_to_channel(@donuts_channel, message)

      {:error, %Ecto.Changeset{} = changeset} ->
        message = "Oops! Error in changeset!" |> URI.encode()
        send_message_to_channel(@donuts_channel, message)
    end
  end

  def check_self_release(donut, sender_id) do
    s_name = Accounts.get_by_slack_id(sender_id) |> Map.get(:name)
    if donut.guilty == s_name do
      :self
    else
      donut
    end
  end

  def send_help() do
    message = "Commands: \n
      donuts_add name surename \n
      donuts_add @slack_name \n
      donuts_release donut_id \n
      donuts_rm donut_id \n
      donuts_add_days donut_id days \n
      donuts_info \n
      donuts_help" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donuts_info(nil) do
    message = "No active donut debts!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donuts_info(active_donuts) do
    active_donuts = active_donuts |> URI.encode()
    send_message_to_channel(@donuts_channel, active_donuts)
  end

  def process_donut_add_days(nil, nil) do
    message = "Oops! Wrong format of the command!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_add_days(nil, days) do
    message = "Oops! Wrong format of the command!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_add_days(donut_target, nil) do
    message = "Oops! Wrong format of the command! Days not specified." |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def process_donut_add_days(donut_target, days) when is_integer(days) do
    f_exp_date =
      donut_target.expiration_date
      |> DateTime.add(days * 24 * 60 * 60, :second)

    RoundPies.update_donut(donut_target, %{:expiration_date => f_exp_date})
    message = "Changed date!" |> URI.encode()
    send_message_to_channel(@donuts_channel, message)
  end

  def get_active_donuts() do
    active_donuts =
      RoundPies.get_all()
      |> Enum.reduce("Active donuts: \n", fn donut, message ->
        donut
        delivered = donut.delivered

        if delivered == false do
          message = "#{message} Guilty: #{donut.guilty} | "
          message = "#{message} Sender: #{donut.sender} | "

          exp_date =
            donut.expiration_date
            |> DateTime.to_date()
            |> Date.to_string()

          message = "#{message} Expiration date: #{exp_date} | "
          message = "#{message} ID: #{donut.id} \n"
        else
          message
        end
      end)
  end
end

defmodule Donuts.SlackCommunicator.Auth do
  @redirect_uri_auth Application.get_env(:donuts, :redirect_uri_auth)
  @client_id Application.get_env(:donuts, :client_id)
  @client_secret Application.get_env(:donuts, :client_secret)

  alias Donuts.Helpers.HTTPHelper

  def get_code(params) do
    params["code"]
  end

  def get_token_info(code) do
    redirect = @redirect_uri_auth |> URI.encode()

    "https://slack.com/api/oauth.access?client_id=#{@client_id}&client_secret=#{@client_secret}&code=#{
      code
    }&redirect_uri=#{redirect}"
    |> HTTPHelper.get_body()
  end
end
