token = "Enter your bot token: " |> IO.gets |> String.trim
HTTPoison.start
{:ok, bot_client } = DiscordEx.Client.start_link(%{
	token: "Bot " <> token,
	handler: ED
})
