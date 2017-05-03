/*	
	Teleports
	
	Checkpoints and teleporting functionality.
*/

#define SOUND_CHECKPOINT "buttons/blip1.wav"
#define SOUND_TELEPORT "buttons/blip1.wav"

// Teleports the player (intended for destination on ground).
// Handles important stuff like storing postion for undo.
void TeleportDo(int client, float destination[3], float eyeAngles[3])
{
	// Store old variables here to avoid incorrect behaviour when teleporting to undo position
	float oldOrigin[3], oldAngles[3];
	g_KZPlayer[client].GetOrigin(oldOrigin);
	g_KZPlayer[client].GetEyeAngles(oldAngles);
	
	g_KZPlayer[client].SetOrigin(destination);
	g_KZPlayer[client].SetEyeAngles(eyeAngles);
	
	g_KZPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	g_KZPlayer[client].SetBaseVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	
	CreateTimer(0.1, Timer_RemoveBoosts, client); // Prevent booster exploits
	
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
	gB_LastTeleportInBhopTrigger[client] = BhopTriggersJustTouched(client);
	
	if (g_TeleportSounds[client])
	{
		EmitSoundToClient(client, SOUND_TELEPORT);
	}
}

void TeleportToStart(int client)
{
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	if (gB_HasStartedThisMap[client])
	{
		// Respawn the player before trying to teleport them
		if (!IsPlayerAlive(client))
		{
			CS_RespawnPlayer(client);
		}
		TeleportDo(client, gF_StartOrigin[client], gF_StartAngles[client]);
		
		if (g_AutoRestart[client] == KZAutoRestart_Enabled)
		{
			TimerStart(client, gI_LastCourseStarted[client], true);
		}
	}
	else
	{
		CS_RespawnPlayer(client);
		gB_Paused[client] = false;
	}
	
	Call_SKZ_OnTeleportToStart(client);
}

void MakeCheckpoint(int client)
{
	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Dead)");
		PlayErrorSound(client);
		return;
	}
	if (!g_KZPlayer[client].onGround)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Midair)");
		PlayErrorSound(client);
		return;
	}
	if (BhopTriggersJustTouched(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Just Landed)");
		PlayErrorSound(client);
		return;
	}
	
	gI_CheckpointCount[client]++;
	gF_LastCheckpointTime[client] = gF_CurrentTime[client];
	g_KZPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
	g_KZPlayer[client].GetEyeAngles(gF_CheckpointAngles[client]);
	
	Call_SKZ_OnMakeCheckpoint(client);
	
	if (g_CheckpointSounds[client] == KZCheckpointSounds_Enabled)
	{
		EmitSoundToClient(client, SOUND_TELEPORT);
	}
	if (g_CheckpointMessages[client] == KZCheckpointMessages_Enabled)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Make Checkpoint");
	}
}

void TeleportToCheckpoint(int client)
{
	if (!IsPlayerAlive(client) || gI_CheckpointCount[client] == 0)
	{
		return;
	}
	if (gB_CurrentMapIsKZPro && gB_TimerRunning[client])
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Teleport (Map)");
		PlayErrorSound(client);
		return;
	}
	
	TeleportDo(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client]);
	
	Call_SKZ_OnTeleportToCheckpoint(client);
}

void UndoTeleport(int client)
{
	if (!IsPlayerAlive(client) || gI_TeleportsUsed[client] < 1)
	{
		return;
	}
	if (!gB_LastTeleportOnGround[client])
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Undo (TP Was Midair)");
		PlayErrorSound(client);
		return;
	}
	if (gB_LastTeleportInBhopTrigger[client])
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Undo (Just Landed)");
		PlayErrorSound(client);
		return;
	}
	
	TeleportDo(client, gF_UndoOrigin[client], gF_UndoAngle[client]);
	
	Call_SKZ_OnUndoTeleport(client);
} 