/*
	Hide CS:GO HUD
	
	Hides elements of the CS:GO HUD.
*/

void HideCSGOHUD(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	CreateTimer(0.0, CleanHUD, client); // Using 1 tick timer or else it won't work	
}



/*===============================  Public Callbacks  ===============================*/

public Action CleanHUD(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		// (1 << 12) Hide Radar
		// (1 << 13) Hide Round Timer
		int clientEntFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
		SetEntProp(client, Prop_Send, "m_iHideHUD", clientEntFlags | (1 << 12) + (1 << 13));
	}
	return Plugin_Continue;
} 