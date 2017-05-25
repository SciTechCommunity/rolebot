defmodule Main do
  def main(args \\ []) do
    case arg do
      [ token | [] ] ->
        HTTPoison.start
        {:ok, bot_client } = DiscordEx.Client.start_link(%{
          token: "Bot " <> String.trim(token),
          handler: ED
        })
        start
      [] -> IO.puts "Please start with a token"
      _ -> IO.puts "Invalid command line args #{args}"
    end
  end
  defp start do
    receive do
      e -> IO.inspect e
    end
    start
  end
end
