/*
	Miscellaneous
	
	Miscellaneous functions.
*/

#define SOUND_ERROR "buttons/button10.wav"

/*===============================  Helper Functions  ===============================*/

// Switches the players team. Handles important stuff like saving and restoring their position.
void JoinTeam(int client, int team)
{
	if (team == CS_TEAM_SPECTATOR)
	{
		g_KZPlayer[client].GetOrigin(gF_SavedOrigin[client]);
		g_KZPlayer[client].GetEyeAngles(gF_SavedAngles[client]);
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
			g_KZPlayer[client].SetOrigin(gF_SavedOrigin[client]);
			g_KZPlayer[client].SetEyeAngles(gF_SavedAngles[client]);
			gB_HasSavedPosition[client] = false;
			if (gB_Paused[client])
			{
				FreezePlayer(client);
			}
		}
		else
		{
			// The player will be teleported to the spawn point, so force stop their timer
			SKZ_ForceStopTimer(client);
		}
	}
	TPMenuUpdate(client);
}

// Returns the player's current run type depending on how many teleports they've used.
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

// Returns which client the player is spectating.
int GetSpectatedClient(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

// Emits a sound to other players that are spectating the client.
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

// Plays the error sound to the client
void PlayErrorSound(int client)
{
	if (IsValidClient(client) && g_ErrorSounds[client] == KZErrorSounds_Enabled)
	{
		EmitSoundToClient(client, SOUND_ERROR);
	}
}

// Puts the player into noclip if they aren't already, or else sets them to normal movement.
void ToggleNoclip(int client)
{
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	if (g_KZPlayer[client].moveType != MOVETYPE_NOCLIP)
	{
		g_KZPlayer[client].moveType = MOVETYPE_NOCLIP;
	}
	else
	{
		g_KZPlayer[client].moveType = MOVETYPE_WALK;
	}
}

// Teleports a player to another target player.
void GotoPlayer(int client, int target)
{
	if (!IsValidClient(client) || !IsValidClient(target) || !IsPlayerAlive(target) || client == target)
	{
		return;
	}
	
	float targetOrigin[3];
	float targetAngles[3];
	
	g_KZPlayer[target].GetOrigin(targetOrigin);
	g_KZPlayer[target].GetEyeAngles(targetAngles);
	
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
	
	TeleportDo(client, targetOrigin, targetAngles);
	
	CPrintToChat(client, "%t %t", "KZ Prefix", "Goto Success", target);
}

// Stops the player and prevents them from moving.
void FreezePlayer(int client)
{
	g_KZPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	g_KZPlayer[client].moveType = MOVETYPE_NONE;
}



/*===============================  Helper Callbacks  ===============================*/

// Slays the player.
public Action Timer_SlayPlayer(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		ForcePlayerSuicide(client);
	}
	return Plugin_Continue;
}

// Removes booster stuff from the player.
public Action Timer_RemoveBoosts(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		g_KZPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
		g_KZPlayer[client].SetBaseVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
		g_KZPlayer[client].gravity = 1.0;
	}
	return Plugin_Continue;
}

// Trace filter do detect player entities
public bool TraceFilterPlayers(int entity, int contentsMask)
{
	return (entity > MaxClients);
} 