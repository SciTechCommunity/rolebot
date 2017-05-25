defmodule ED do

  defp send_message(msg, ch, conn), do: DiscordEx.RestClient.Resources.Channel.send_message conn, ch, %{content: msg}
  defp add_member_role(conn), do: DiscordEx.RestClient.resource conn, :put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", %{}
  defp get_guild_roles(conn, guild), do: DiscordEx.RestClient.Resources.Guild.roles conn, guild
  
  defp _greet, do: ["Hello!", "Hi!", "Hey!", "Howdy!", "Hiya!", "HeyHi!", "Greetings!"]
  def greet(conn, channel) do
    _greet()
      |> Enum.random
      |> send_message(channel, conn)
      |> IO.inspect
  end
  
  defp get_colors do
    { colors, _ } = Code.eval_file "colors.exs", "lib"
    colors
  end
  def get_role_color(role) do
    format = fn x -> x |> URI.encode_www_form |> String.upcase |> String.to_atom end
    color = case Process.get :colors do
      nil ->
        Process.put :colors, get_colors()
        {:ok, get_role_color role}
      colors when Kernel.is_map(colors) ->
        {:ok, colors |> Map.get format.(role) }
      _ -> :error
    end
    color
  end
  def add_language_role(role, state, payload) do
    send_msg = fn msg -> send_message msg, payload["channel_id"], state[:rest_client] end
    no_role = "The language #{role} is currently unsupported, " <>
    "please contact @shadow if you would like to add this language."
    case get_role_color role do
      {:ok, nil} ->  send_msg.(no_role)
      {:ok, _color} ->
        [guild | _] = state[:guilds]
        state[:rest_client]
          |> get_guild_roles(guild[:guild_id])
          |> IO.inspect
      send_msg.("You have been added to the #{role} group!")
      :error -> send_msg.("There was an error with your request!")
    end |> IO.inspect
  end
  
  def handle_event({:message_create, payload}, state) do
    IO.puts "Received Message Create Event"
    case payload |> DiscordEx.Client.Helpers.MessageHelper.msg_command_parse do
      { "hello", _ } -> greet state[:rest_client], payload[:data]["channel_id"]
      { "add", "role " <> role } -> add_language_role role, state, payload[:data]
      other -> other
    end
    {:ok, state}
  end 
  def handle_event({event, _payload}, state) do
    IO.puts "Received Event: #{event}"
    {:ok, state}
  end

end
