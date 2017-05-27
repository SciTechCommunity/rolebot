defmodule ED do

  defp send_message(msg, ch, conn), do: DiscordEx.RestClient.Resources.Channel.send_message conn, ch, %{content: msg}
  defp delete_message(msg, ch, conn), do: DiscordEx.RestClient.Resources.Channel.delete_message conn, ch, msg
  defp add_member_role(conn, guild_id, user_id, role_id), do: DiscordEx.RestClient.resource conn, :put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", %{}
  defp get_guild_roles(conn, guild), do: DiscordEx.RestClient.Resources.Guild.roles conn, guild
  defp add_new_role(conn, guild_id, name, color), do: DiscordEx.RestClient.resource conn, :post, "/guilds/#{guild_id}/roles", %{name: name, color: color, mentionable: true}
  
  defp _greet, do: ["Hello!", "Hi!", "Hey!", "Howdy!", "Hiya!", "HeyHi!", "Greetings!"]
  def greet(conn, channel), do: _greet |> Enum.random |> send_message(channel, conn) |> IO.inspect
  
  defp channels(ch), do: Access.get %{317915118060961793 => :welcome}, ch
  defp roles(r), do: Access.get %{visitor: 292739861767782401, member: 235927353832767498}, r
  defp welcome(payload, state) do
    case channels payload["channel_id"] do
      :welcome ->
        [ guild | _ ] = state[:guilds]
        add_member_role state[:rest_client], guild[:guild_id], payload["author"]["id"], roles(:visitor)
        delete_message payload["id"], payload["channel_id"], state[:rest_client]
      nil -> {:unknown, payload["channel_id"]}
    end
  end
  
  defp language_role_help(conn, ch) do
    send_message """
    ***#{_greet()|> Enum.random}***
    So you want to add a language role?
    It's simple! all you have to do is type
    `!add role <language>` where language is
    the language you would like to add!
    You can get a full list of languages @
    https://github.com/ShadowfeindX/erl_discord
    """, ch, conn
  end
  
  defp get_colors do
    { colors, _ } = Code.eval_file "colors.exs", "lib"
    colors
  end
  defp get_role_color(role) do
    format = fn x -> x |> URI.encode_www_form |> String.upcase |> String.to_atom end
    color = case Process.get :colors do
      nil ->
        Process.put :colors, get_colors()
        get_role_color role
      colors when Kernel.is_map(colors) ->
        {:ok, colors |> Map.get format.(role)}
      _ -> :error
    end
    color
  end
  def add_language_role(role, role_color, state, payload) do
    send_msg = fn msg -> send_message msg, payload["channel_id"], state[:rest_client] end
    seek_role = fn r -> String.upcase(r["name"]) == String.upcase(role) end
    no_role = "The language #{role} is currently unsupported, " <>
    "please contact <@249991058132434945> if you would like to add this language."
    case role_color do
      :error -> send_msg.("There was an error with your request!")
      {:ok, nil} ->  send_msg.(no_role)
      {:ok, color} ->
        [guild | _] = state[:guilds]
        case state[:rest_client]
          |> get_guild_roles(guild[:guild_id])
          |> Enum.find(seek_role) do
          nil -> 
            add_new_role state[:rest_client], guild[:guild_id], role, color
            add_language_role role, role_color, state, payload
          r ->
            add_member_role state[:rest_client], guild[:guild_id], payload["author"]["id"], r["id"]
            send_msg.("You have been added to the #{role} group!")
        end
    end
  end
  
  def handle_event({:message_create, payload}, state) do
    case payload |> DiscordEx.Client.Helpers.MessageHelper.msg_command_parse do
      { "hello", _ } -> greet state[:rest_client], payload[:data]["channel_id"]
      { nil, "confirm" } -> welcome payload[:data], state
      { "roles", _ } -> language_role_help state[:rest_client], payload[:data]["channel_id"]
      { "add", "role " <> role } ->
        params = [role, role |> get_role_color, state, payload[:data]]
        spawn ED, :add_language_role, params
      other -> other
    end |> IO.inspect
    {:ok, state}
  end 
  def handle_event({event, _payload}, state) do
    IO.puts "Received Event: #{event}"
    {:ok, state}
  end

end
