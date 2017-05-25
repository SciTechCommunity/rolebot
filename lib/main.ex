defmodule Main do
  def main(_args \\ []) do
    token = "Enter your bot token: " |> IO.gets |> String.trim
    HTTPoison.start
    {:ok, bot_client } = DiscordEx.Client.start_link(%{
      token: "Bot " <> token,
      handler: ED
    })
    start
  end
  defp start do
    receive do
      e -> IO.inspect e
    end
    start
  end
end
