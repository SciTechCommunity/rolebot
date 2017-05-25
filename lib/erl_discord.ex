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
  
  def add_member_role(role, state, payload) do
    format = fn x -> x |> URI.encode_www_form |> String.upcase end
    case Process.get :colors do
      nil -> Process.put :colors, (Code.eval_file "colors.exs", "lib")
      colors -> IO.inspect {role, colors[:"#{format.(role)}"], payload}
    end
  end
  
  def handle_event({:message_create, payload}, state) do
    IO.puts "Received Message Create Event"
    case payload |> DiscordEx.Client.Helpers.MessageHelper.msg_command_parse do
      {"hello", _} -> greet state[:rest_client], payload[:data]["channel_id"]
      {"add", "role " <> role} -> add_member_role role, state[:rest_client], payload[:data]
      other -> other |> IO.inspect
    end
    {:ok, state}
  end 
  def handle_event({event, _payload}, state) do
    IO.puts "Received Event: #{event}"
    {:ok, state}
  end

end
