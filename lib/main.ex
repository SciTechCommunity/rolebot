defmodule Main do
  def main(args \\ []) do
    case args do
      [ token | [] ] ->
        HTTPoison.start
        {:ok, bot_client } = DiscordEx.Client.start_link(%{
          token: "Bot " <> String.trim(token),
          handler: ED
        })
        Process.unlink bot_client
        Process.monitor bot_client
        start args
      [] -> IO.puts "Please start with a token"
      _ -> IO.puts "Invalid command line args #{args}"
    end
  end
  defp start(args) do
    receive do
      {:DOWN, _ref, _type, _pid, _info} ->
        IO.inspect {_ref, _type, _pid, _info}
        main args
      e -> IO.inspect e
    end
    start args
  end
end
