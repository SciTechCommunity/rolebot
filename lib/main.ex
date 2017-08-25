defmodule Main do
  def main(args \\ []) do
    case args do
      [ token | [] ] ->
        DiscordEx.Connections.REST.start
        {:ok, bot_client } = DiscordEx.Client.start_link %{
          token: token |> String.trim,
          handler: ED
        }
        Process.unlink bot_client
        Process.monitor bot_client
        start args
      [] -> IO.puts "Please start with a token"
      _ -> IO.puts "Invalid command line args #{args}"
    end
  end
  defp start(args) do
    receive do
      e ->
        IO.inspect e
    end
    main args
  end
end
