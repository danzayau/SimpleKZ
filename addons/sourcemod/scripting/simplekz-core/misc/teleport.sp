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
	else if (!g_MovementPlayer[client].onGround)
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
		g_MovementPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
		g_MovementPlayer[client].GetEyeAngles(gF_CheckpointAngles[client]);
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