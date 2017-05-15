/*	
	Teleports
	
	Checkpoints and teleporting functionality.
*/



#define SOUND_CHECKPOINT "buttons/blip1.wav"
#define SOUND_TELEPORT "buttons/blip1.wav"

static int checkpointCount[MAXPLAYERS + 1];
static int teleportCount[MAXPLAYERS + 1];
static float startOrigin[MAXPLAYERS + 1][3];
static float startAngles[MAXPLAYERS + 1][3];
static float checkpointOrigin[MAXPLAYERS + 1][3];
static float checkpointAngles[MAXPLAYERS + 1][3];
static bool lastTeleportOnGround[MAXPLAYERS + 1];
static bool lastTeleportInBhopTrigger[MAXPLAYERS + 1];
static float undoOrigin[MAXPLAYERS + 1][3];
static float undoAngles[MAXPLAYERS + 1][3];



// =========================  PUBLIC  ========================= //

int GetCheckpointCount(int client)
{
	return checkpointCount[client];
}

int GetTeleportCount(int client)
{
	return teleportCount[client];
}

void MakeCheckpoint(int client)
{
	// Guards
	if (!IsPlayerAlive(client))
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Checkpoint (Dead)");
		PlayErrorSound(client);
		return;
	}
	if (!Movement_GetOnGround(client))
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Checkpoint (Midair)");
		PlayErrorSound(client);
		return;
	}
	if (BhopTriggersJustTouched(client))
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Checkpoint (Just Landed)");
		PlayErrorSound(client);
		return;
	}
	
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnMakeCheckpoint(client, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// Make Checkpoint
	checkpointCount[client]++;
	Movement_GetOrigin(client, checkpointOrigin[client]);
	Movement_GetEyeAngles(client, checkpointAngles[client]);
	if (GetOption(client, Option_CheckpointSounds) == CheckpointSounds_Enabled)
	{
		EmitSoundToClient(client, SOUND_TELEPORT);
	}
	if (GetOption(client, Option_CheckpointMessages) == CheckpointMessages_Enabled)
	{
		SKZ_PrintToChat(client, true, "%t", "Make Checkpoint");
	}
	
	// Call Post Forward
	Call_SKZ_OnMakeCheckpoint_Post(client);
}

void TeleportToCheckpoint(int client)
{
	// Guards
	if (!IsPlayerAlive(client))
	{
		return;
	}
	if (checkpointCount[client] == 0)
	{
		// TODO Error message
		return;
	}
	if (GetCurrentMapPrefix() == MapPrefix_KZPro && GetTimerRunning(client))
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Teleport (Map)");
		PlayErrorSound(client);
		return;
	}
	
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnTeleportToCheckpoint(client, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// Teleport to Checkpoint
	TeleportDo(client, checkpointOrigin[client], checkpointAngles[client]);
	
	// Call Post Forward
	Call_SKZ_OnTeleportToCheckpoint_Post(client);
}

void TeleportToStart(int client)
{
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnTeleportToStart(client, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// Teleport to Start
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	if (GetHasStartedTimerThisMap(client))
	{
		if (!IsPlayerAlive(client))
		{
			CS_RespawnPlayer(client);
		}
		TeleportDo(client, startOrigin[client], startAngles[client]);
	}
	else
	{
		CS_RespawnPlayer(client);
	}
	
	// Call Post Forward
	Call_SKZ_OnTeleportToStart_Post(client);
}

void UndoTeleport(int client)
{
	// Guards
	if (!IsPlayerAlive(client))
	{
		return;
	}
	if (teleportCount[client] <= 0)
	{
		// TODO Error message
		return;
	}
	if (!lastTeleportOnGround[client])
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Undo (TP Was Midair)");
		PlayErrorSound(client);
		return;
	}
	if (lastTeleportInBhopTrigger[client])
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Undo (Just Landed)");
		PlayErrorSound(client);
		return;
	}
	
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnUndoTeleport(client, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// Undo Teleport
	TeleportDo(client, undoOrigin[client], undoAngles[client]);
	
	// Call Post Forward
	Call_SKZ_OnUndoTeleport_Post(client);
}

void GotoPlayer(int client, int target)
{
	if (!IsValidClient(client) || !IsValidClient(target) || !IsPlayerAlive(target) || client == target)
	{
		return;
	}
	
	float targetOrigin[3];
	float targetAngles[3];
	
	Movement_GetOrigin(target, targetOrigin);
	Movement_GetEyeAngles(target, targetAngles);
	
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
	
	SKZ_PrintToChat(client, true, "%t", "Goto Success", target);
}



// =========================  LISTENERS  ========================= //

void OnTimerStart_Teleports(int client)
{
	checkpointCount[client] = 0;
	teleportCount[client] = 0;
	Movement_GetOrigin(client, startOrigin[client]);
	Movement_GetEyeAngles(client, startAngles[client]);
}



// =========================  PRIVATE  ========================= //

static void TeleportDo(int client, const float destOrigin[3], const float destAngles[3])
{
	// Store information about where player is teleporting from
	float oldOrigin[3];
	Movement_GetOrigin(client, oldOrigin);
	float oldAngles[3];
	Movement_GetEyeAngles(client, oldAngles);
	lastTeleportInBhopTrigger[client] = BhopTriggersJustTouched(client);
	lastTeleportOnGround[client] = Movement_GetOnGround(client);
	
	// Do Teleport
	teleportCount[client]++;
	Movement_SetOrigin(client, destOrigin);
	Movement_SetEyeAngles(client, destAngles);
	Movement_SetVelocity(client, view_as<float>( { 0.0, 0.0, 0.0 } ));
	Movement_SetBaseVelocity(client, view_as<float>( { 0.0, 0.0, 0.0 } ));
	Movement_SetGravity(client, 1.0);
	CreateTimer(0.1, Timer_RemoveBoosts, client); // Prevent booster exploits
	
	undoOrigin[client] = oldOrigin;
	undoAngles[client] = oldAngles;
	
	if (GetOption(client, Option_TeleportSounds) == TeleportSounds_Enabled)
	{
		EmitSoundToClient(client, SOUND_TELEPORT);
	}
}

public Action Timer_RemoveBoosts(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		Movement_SetVelocity(client, view_as<float>( { 0.0, 0.0, 0.0 } ));
		Movement_SetBaseVelocity(client, view_as<float>( { 0.0, 0.0, 0.0 } ));
		Movement_SetGravity(client, 1.0);
	}
	return Plugin_Continue;
} 