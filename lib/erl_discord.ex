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


token = IO.gets "Enter your bot token: "
{:ok, bot_client } = DiscordEx.Client.start_link(%{
	token: token,
	handler: ED
})
