defmodule ED do
  @moduledoc """
  Documentation for ED.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ED.hello
      :world

  """
  def hello do
    :world
  end
  
  defp send_message(msg, ch, conn), do: DiscordEx.RestClient.Resources.Channel.send_message conn, ch, %{content: msg}
  
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
      nil -> Process.put :colors, get_colors |> (&(get_role_color role)).()
      colors when Kernel.is_map(colors) -> {:ok, Map.get(colors, format.(role))}
      _ -> :error
    end
    color
  end
  def add_member_role(role, state, payload) do
    _send = fn msg -> send_message msg, payload["channel_id"], state[:rest_client] end
    valid_role = "The language #{role} is currently unsupported, " <>
    "please contact @shadow if you would like to add this language."
    case get_valid_roles do
      {:ok, nil} -> _send.(valid_role)
      {:ok, color} -> _send.("You have been added to the #{role} group!")
      :error -> _send.("There was an error with your request!")
    end
  end
  
  def handle_event({:message_create, payload}, state) do
    IO.puts "Received Message Create Event"
    case payload |> DiscordEx.Client.Helpers.MessageHelper.msg_command_parse do
      { "hello", _ } -> greet state[:rest_client], payload[:data]["channel_id"]
      { "add", "role " <> role } -> add_member_role role, state[:rest_client], payload[:data]
      other -> other
    end |> IO.inspect
    {:ok, state}
  end 
  def handle_event({event, _payload}, state) do
    IO.puts "Received Event: #{event}"
    {:ok, state}
  end

end
