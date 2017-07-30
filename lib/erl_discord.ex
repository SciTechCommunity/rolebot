defmodule ED do

  defp send_message(msg, ch, conn), do: DiscordEx.RestClient.Resources.Channel.send_message conn, ch, %{content: msg}
  defp delete_message(msg, ch, conn), do: DiscordEx.RestClient.Resources.Channel.delete_message conn, ch, msg
  defp add_member_role(conn, guild_id, user_id, role_id), do: DiscordEx.RestClient.resource conn, :put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", %{}
  defp get_guild_roles(conn, guild), do: DiscordEx.RestClient.Resources.Guild.roles conn, guild
  defp add_new_role(conn, guild_id, name, color), do: DiscordEx.RestClient.resource conn, :post, "/guilds/#{guild_id}/roles", %{name: name, color: color, mentionable: true}
  
  defp _greet, do: ["Hello!", "Hi!", "Hey!", "Howdy!", "Hiya!", "HeyHi!", "Greetings!"]
  def greet(conn, channel), do: _greet() |> Enum.random |> send_message(channel, conn) |> IO.inspect
  def greet_member(conn, member), do: _greet() |> Enum.random |> fn msg -> "#{msg} <@#{member}>" end . () |> send_message(channel_by_name(:general), conn) |> IO.inspect
  
  defp channel_by_id(ch), do: Access.get %{317915118060961793 => :welcome}, ch
  defp channel_by_name(ch), do: Access.get %{general: 232641658712358912}, ch
  defp roles(r), do: Access.get %{visitor: 292739861767782401, member: 235927353832767498}, r

  defp welcome(payload, state) do
    case channel_by_id payload["channel_id"] do
      :welcome ->
        [ guild | _ ] = state[:guilds]
        add_member_role state[:rest_client], guild[:guild_id], payload["author"]["id"], roles(:visitor)
        delete_message payload["id"], payload["channel_id"], state[:rest_client]
        greet_member state[:rest_client], payload["author"]["id"]
      nil -> {:unknown, payload["channel_id"]}
    end
  end
  
  defp show_author(conn, ch) do
    send_message """
    I was created by the one and only <@249991058132434945>!
    Check out more of his mediocre code @ https://github.com/ShadowfeindX
    """, ch, conn
  end

  defp show_source(conn, ch) do
    send_message """
    You can find my source in our community repository!
    https://github.com/TumblrCommunity/rolebot
    """, ch, conn
  end
  
  defp language_role_help(conn, ch) do
    send_message """
    ***#{_greet()|> Enum.random}***
    So you want to add a language role?
    It's simple! all you have to do is type
    `@rolebot add lang <language>` where language is
    the language you would like to add!
    You can get a full list of languages @
    https://github.com/TumblrCommunity/rolebot
    """, ch, conn
  end
  
  defp get_role_color(role) do
    format = fn x -> x |> URI.encode(&(&1 != ?\s and &1 != ?+ and &1 != ?#)) |> String.upcase |> String.to_atom end
    color = case Process.get :colors do
      colors when is_map(colors) ->
        {:ok, colors |> Map.get(format.(role))}
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
  
  def handle_event({:guild_create, payload}, state) do
	DiscordEx.Client.status_update state, %{game_name: "The gift of language"}
	{ colors, _ } = Code.eval_file "colors.exs", "lib"
	Process.put :colors, colors
	payload |> IO.inspect
	{:ok, state}
  end
  def handle_event({:message_create, payload}, state) do
	client = "<@#{state[:client_id]}>"	
	lang_help = fn -> language_role_help state[:rest_client], payload[:data]["channel_id"] end
    case payload |> DiscordEx.Client.Helpers.MessageHelper.msg_command_parse("#{client} ") do
      { "hello", _ } -> greet state[:rest_client], payload[:data]["channel_id"]
      { "help", _ } -> lang_help.()
      { "source", _ } -> show_source state[:rest_client], payload[:data]["channel_id"]
      { "author", _ } -> show_author state[:rest_client], payload[:data]["channel_id"]
      { nil, "confirm" } -> welcome payload[:data], state
      { nil, ^client } -> lang_help.()
      { nil, msg } -> msg
      { "add", "lang " <> lang } ->
        params = [lang, lang |> get_role_color, state, payload[:data]]
        spawn ED, :add_language_role, params
      { _unknown, _command } -> lang_help.()
      _ -> :parse_error
    end |> IO.inspect
    {:ok, state}
  end 
  def handle_event({event, _payload}, state) do
    IO.puts "Received Event: #{event}"
    {:ok, state}
  end

end
