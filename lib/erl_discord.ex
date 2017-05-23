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

{:ok, bot_client } = DiscordEx.Client.start_link(%{
	token: MzA2MjY0NjMzNjkyMzg5Mzg2.DAUuUw.7_U4Oqg7x5Mn90BfRzzrD02gnGE,
	handler: ED
})
