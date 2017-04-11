/*    
    Client
    
    Miscellaneous client related functions.
*/


void SetupClient(int client)
{
	SetDefaultOptions(client);
	SetupTimer(client);
	NoBhopBlockCPSetup(client);
	Call_SimpleKZ_OnClientSetup(client);
}

void PrintConnectMessage(int client)
{
	char name[MAX_NAME_LENGTH], clientIP[32], country[45];
	GetClientName(client, name, MAX_NAME_LENGTH);
	GetClientIP(client, clientIP, sizeof(clientIP));
	if (!GeoipCountry(clientIP, country, sizeof(country)))
	{
		country = "Unknown";
	}
	CPrintToChatAll("%T", "Client Connection Message", client, name, country);
}

void PrintDisconnectMessage(int client, const char[] reason)
{
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, MAX_NAME_LENGTH);
	CPrintToChatAll("%T", "Client Disconnection Message", client, name, reason);
}

void JoinTeam(int client, int team)
{
	if (team == CS_TEAM_SPECTATOR)
	{
		g_MovementPlayer[client].GetOrigin(gF_SavedOrigin[client]);
		g_MovementPlayer[client].GetEyeAngles(gF_SavedAngles[client]);
		gB_HasSavedPosition[client] = true;
		if (gB_TimerRunning[client])
		{
			Pause(client);
		}
		ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	}
	else if (team == CS_TEAM_CT || team == CS_TEAM_T)
	{
		// Switch teams without killing them (no death notice)
		CS_SwitchTeam(client, team);
		CS_RespawnPlayer(client);
		if (gB_HasSavedPosition[client])
		{
			TeleportEntity(client, gF_SavedOrigin[client], gF_SavedAngles[client], view_as<float>( { 0.0, 0.0, -50.0 } ));
			gB_HasSavedPosition[client] = false;
			if (gB_Paused[client])
			{
				FreezePlayer(client);
			}
		}
		else
		{
			// The player will be teleported to the spawn point, so force stop their timer
			SimpleKZ_ForceStopTimer(client);
		}
	}
	CloseTPMenu(client);
}

void SetDrawViewModel(int client, bool drawViewModel)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", drawViewModel);
}

void GotoPlayer(int client, int target)
{
	float targetOrigin[3];
	float targetAngles[3];
	
	g_MovementPlayer[target].GetOrigin(targetOrigin);
	g_MovementPlayer[target].GetEyeAngles(targetAngles);
	
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	// Respawn the player if necessary
	if (!IsPlayerAlive(client))
	{
		CS_RespawnPlayer(client);
	}
	TeleportEntity(client, targetOrigin, targetAngles, view_as<float>( { 0.0, 0.0, -100.0 } ));
	CPrintToChat(client, "%t %t", "KZ Prefix", "Goto Success", target);
}

void FreezePlayer(int client)
{
	g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	g_MovementPlayer[client].moveType = MOVETYPE_NONE;
}

void ToggleNoclip(int client)
{
	if (g_MovementPlayer[client].moveType != MOVETYPE_NOCLIP)
	{
		g_MovementPlayer[client].moveType = MOVETYPE_NOCLIP;
	}
	else
	{
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	}
}

KZTimeType GetCurrentTimeType(int client)
{
	if (gI_TeleportsUsed[client] == 0)
	{
		return KZTimeType_Pro;
	}
	else
	{
		return KZTimeType_Normal;
	}
}

void UpdatePlayerModel(int client)
{
	if (GetClientTeam(client) == CS_TEAM_T)
	{
		SetEntityModel(client, gC_PlayerModelT);
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityModel(client, gC_PlayerModelCT);
	}
}

void UpdatePlayerPistol(int client)
{
	GivePlayerPistol(client, g_Pistol[client]);
}

void GivePlayerPistol(int client, KZPistol pistol)
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

int GetSpectatedClient(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

void EmitSoundToClientSpectators(int client, const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetSpectatedClient(i) == client)
		{
			EmitSoundToClient(i, sound);
		}
	}
}

void UpdateWeaponVisibility(int client)
{
	if (g_ShowingWeapon[client] == KZShowingWeapon_Enabled)
	{
		SetDrawViewModel(client, true);
	}
	else
	{
		SetDrawViewModel(client, false);
	}
}

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

public Action SlayPlayer(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		ForcePlayerSuicide(client);
	}
	return Plugin_Continue;
}

public Action ZeroVelocity(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, -0.0 } ));
		g_MovementPlayer[client].SetBaseVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	}
	return Plugin_Continue;
} 