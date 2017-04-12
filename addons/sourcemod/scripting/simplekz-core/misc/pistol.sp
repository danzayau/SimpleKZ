/*
	Pistol
	
	Give players the pistol they like.
*/

// Gives the player the pistol specified by their pistol option.
void PistolUpdate(int client)
{
	GivePlayerPistol(client, g_Pistol[client]);
}



/*===============================  Static Functions  ===============================*/

static void GivePlayerPistol(int client, KZPistol pistol)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	int playerTeam = GetClientTeam(client);
	// Switch teams to the side that buys that gun so that gun skins load
	if (StrEqual(gC_Pistols[pistol][2], "CT") && playerTeam != CS_TEAM_CT)
	{
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	else if (StrEqual(gC_Pistols[pistol][2], "T") && playerTeam != CS_TEAM_T)
	{
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	// Give the player this pistol
	int currentPistol = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (currentPistol != -1)
	{
		RemovePlayerItem(client, currentPistol);
	}
	GivePlayerItem(client, gC_Pistols[pistol][0]);
	// Go back to original team
	if (1 <= playerTeam && playerTeam <= 3)
	{
		CS_SwitchTeam(client, playerTeam);
	}
} 