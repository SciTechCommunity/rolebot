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
  
  def handle_event({event, _payload}, state) do
    IO.puts "Received Event: #{event}"
    {:ok, state}
  end

end


token = "Enter your bot token: " |> IO.gets |> String.trim
HTTPoison.start
{:ok, bot_client } = DiscordEx.Client.start_link(%{
	token: "Bot " <> token,
	handler: ED
})
