/*	
	Teleporting
	
	Checkpoints and teleporting functionality.
*/

#define SOUND_CHECKPOINT "buttons/blip1.wav"
#define SOUND_TELEPORT "buttons/blip1.wav"

void TeleportToStart(int client)
{
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	if (gB_HasStartedThisMap[client])
	{
		// Respawn the player if necessary
		if (!IsPlayerAlive(client))
		{
			CS_RespawnPlayer(client);
		}
		// Stop the timer if on a kzpro_ map
		if (gB_CurrentMapIsKZPro)
		{
			gB_TimerRunning[client] = false;
		}
		AddWastedTimeTeleportToStart(client);
		DoTeleport(client, gF_StartOrigin[client], gF_StartAngles[client]);
		if (g_AutoRestart[client] == KZAutoRestart_Enabled)
		{
			TimerStart(client, gI_LastCourseStarted[client]);
		}
	}
	else
	{
		CS_RespawnPlayer(client);
	}
	CloseTPMenu(client);
}

void MakeCheckpoint(int client)
{
	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Dead)");
	}
	else if (!g_KZPlayer[client].onGround)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Midair)");
	}
	else if (JustTouchedBhopBlock(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Just Landed)");
	}
	else
	{
		gI_CheckpointCount[client]++;
		gF_LastCheckpointTime[client] = gF_CurrentTime[client];
		g_KZPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
		g_KZPlayer[client].GetEyeAngles(gF_CheckpointAngles[client]);
		if (g_CheckpointMessages[client] == KZCheckpointMessages_Enabled)
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "Make Checkpoint");
		}
		if (g_CheckpointSounds[client] == KZCheckpointSounds_Enabled)
		{
			EmitSoundToClient(client, SOUND_TELEPORT);
		}
	}
	CloseTPMenu(client);
}

void TeleportToCheckpoint(int client)
{
	if (!IsPlayerAlive(client) || gI_CheckpointCount[client] == 0)
	{
		return;
	}
	else if (gB_CurrentMapIsKZPro && gB_TimerRunning[client])
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Teleport (Map)");
	}
	else
	{
		AddWastedTimeTeleportToCheckpoint(client);
		DoTeleport(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client]);
		if (g_TeleportSounds[client] == KZTeleportSounds_Enabled)
		{
			EmitSoundToClient(client, SOUND_TELEPORT);
		}
	}
	CloseTPMenu(client);
}

void UndoTeleport(int client)
{
	if (!IsPlayerAlive(client) || gI_TeleportsUsed[client] < 1)
	{
		return;
	}
	else if (!gB_LastTeleportOnGround[client])
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Undo (TP Was Midair)");
	}
	else
	{
		AddWastedTimeUndoTeleport(client);
		DoTeleport(client, gF_UndoOrigin[client], gF_UndoAngle[client]);
		if (g_TeleportSounds[client])
		{
			EmitSoundToClient(client, SOUND_TELEPORT);
		}
	}
	CloseTPMenu(client);
}



/*===============================  Static Functions  ===============================*/

// Teleports the player (intended for destination on ground).
// Handles important stuff like storing postion for undo.
static void DoTeleport(int client, float destination[3], float eyeAngles[3])
{
	// Store old variables here to avoid incorrect behaviour when teleporting to undo position
	float oldOrigin[3], oldAngles[3];
	g_KZPlayer[client].GetOrigin(oldOrigin);
	g_KZPlayer[client].GetEyeAngles(oldAngles);
	
	TeleportEntity(client, destination, eyeAngles, view_as<float>( { 0.0, 0.0, -50.0 } ));
	CreateTimer(0.0, Timer_ZeroVelocity, client); // Prevent booster exploits
	gI_TeleportsUsed[client]++;
	// Store position for undo
	if (g_KZPlayer[client].onGround)
	{
		gB_LastTeleportOnGround[client] = true;
		gF_UndoOrigin[client] = oldOrigin;
		gF_UndoAngle[client] = oldAngles;
	}
	else
	{
		gB_LastTeleportOnGround[client] = false;
	}
} 