/*
	Hide Players
	
	Controls visiblity of other players.
*/

// Sets up an SDKHook_SetTransmit hook on clients.
void HidePlayersSetupClient(int client)
{
	SDKHook(client, SDKHook_SetTransmit, OnSetTransmitClient);
}



/*===============================  Public Callbacks  ===============================*/

// Blocks other players from being transmitted (hides other players).
public Action OnSetTransmitClient(int entity, int client)
{
	if (g_ShowingPlayers[client] == KZShowingPlayers_Disabled
		 && entity != client
		 && (!IsSpectatingSomeone(client) || entity != GetObserverTarget(client)))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
} 