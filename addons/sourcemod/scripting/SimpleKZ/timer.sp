/*	timer.sp

	Timer and checkpoint/teleport system.
*/


void TimerTick(int client) {
	if (IsPlayerAlive(client) && gB_TimerRunning[client] && !gB_Paused[client]) {
		gF_CurrentTime[client] += GetTickInterval();
	}
}

void SetupTimer(int client) {
	gB_TimerRunning[client] = false;
	gB_HasStartedThisMap[client] = false;
	TimerRestart(client);
}

void TimerRestart(int client) {
	gF_CurrentTime[client] = 0.0;
	gB_Paused[client] = false;
	gF_LastResumeTime[client] = 0.0;
	gB_HasResumedInThisRun[client] = false;
	gI_CheckpointsSet[client] = 0;
	gI_TeleportsUsed[client] = 0;
	gF_LastCheckpointTime[client] = 0.0;
	gF_LastGoCheckTime[client] = 0.0;
	gF_LastGoCheckWastedTime[client] = 0.0;
	gF_LastUndoTime[client] = 0.0;
	gF_LastUndoWastedTime[client] = 0.0;
	gF_LastTeleportToStartTime[client] = 0.0;
	gF_LastTeleportToStartWastedTime[client] = 0.0;
	gF_WastedTime[client] = 0.0;
	gB_HasSavedPosition[client] = false;
	ResetSplits(client);
}

void StartTimer(int client) {
	Call_SimpleKZ_OnTimerStarted(client);
	EmitSoundToClient(client, "buttons/button9.wav");
	EmitSoundToClientSpectators(client, "buttons/button9.wav");
	TimerRestart(client);
	gB_TimerRunning[client] = true;
	if (!gB_HasStartedThisMap[client]) {
		gB_HasStartedThisMap[client] = true;
	}
	CloseTeleportMenu(client);
}

void EndTimer(int client) {
	Call_SimpleKZ_OnTimerEnded(client);
	EmitSoundToClient(client, "buttons/bell1.wav");
	EmitSoundToClientSpectators(client, "buttons/bell1.wav");
	gB_TimerRunning[client] = false;
	PrintEndTimeString(client);
	CloseTeleportMenu(client);
}

void ForceStopTimer(int client) {
	gB_TimerRunning[client] = false;
	gB_Paused[client] = false;
}

void TimerDoTeleport(int client, float destination[3], float eyeAngles[3]) {
	// Store old variables here to avoid incorrect behaviour when teleporting to undo position
	float oldOrigin[3], oldAngles[3];
	g_MovementPlayer[client].GetOrigin(oldOrigin);
	g_MovementPlayer[client].GetEyeAngles(oldAngles);
	
	TeleportEntity(client, destination, eyeAngles, view_as<float>( { 0.0, 0.0, -50.0 } ));
	gI_TeleportsUsed[client]++;
	// Store position for undo
	if (g_MovementPlayer[client].onGround) {
		gB_LastTeleportOnGround[client] = true;
		gF_UndoOrigin[client] = oldOrigin;
		gF_UndoAngle[client] = oldAngles;
	}
	else {
		gB_LastTeleportOnGround[client] = false;
	}
}



/*===============================  Start and End Buttons  ===============================*/

public void OnButtonPress(const char[] name, int caller, int activator, float delay) {
	if (IsValidEntity(caller) && IsValidClient(activator)) {
		char tempString[32];
		// Get the class name of the activator
		GetEdictClassname(activator, tempString, sizeof(tempString));
		if (StrEqual(tempString, "player")) {
			// Get the name of the pressed func_button
			GetEntPropString(caller, Prop_Data, "m_iName", tempString, sizeof(tempString));
			// Check if button entity name is something we want to do something with
			if (StrEqual(tempString, "climb_startbutton", false)) {
				StartButtonPress(activator);
			}
			else if (StrEqual(tempString, "climb_endbutton", false)) {
				EndButtonPress(activator);
			}
		}
	}
}

void StartButtonPress(int client) {
	// Have to be on ground and not noclipping to start the timer
	if (g_MovementPlayer[client].onGround && !g_MovementPlayer[client].noclipping) {
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
		g_MovementPlayer[client].GetOrigin(gF_StartOrigin[client]);
		g_MovementPlayer[client].GetEyeAngles(gF_StartAngles[client]);
		StartTimer(client);
	}
}

void EndButtonPress(int client) {
	if (gB_TimerRunning[client]) {
		EndTimer(client);
	}
}

void CheckForStartButtonPress(int client) {
	// If didnt just start time, and just pressed +use button
	if (!(gB_TimerRunning[client] && gF_CurrentTime[client] < 0.1)
		 && !(g_OldButtons[client] & IN_USE) && GetClientButtons(client) & IN_USE) {
		// If player is at their start position, start their timer and update their start angles
		float origin[3];
		g_MovementPlayer[client].GetOrigin(origin);
		if (GetVectorDistance(origin, gF_StartOrigin[client]) == 0.0) {
			g_MovementPlayer[client].GetEyeAngles(gF_StartAngles[client]);
			StartTimer(client);
		}
	}
	g_OldButtons[client] = GetClientButtons(client);
}



/*===============================  Timer Commands  ===============================*/

void TeleportToStart(int client) {
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	if (gB_HasStartedThisMap[client]) {
		// Respawn the player if necessary
		if (!IsPlayerAlive(client)) {
			CS_RespawnPlayer(client);
		}
		// Stop the timer if on a kzpro_ map
		if (gB_CurrentMapIsKZPro) {
			gB_TimerRunning[client] = false;
		}
		AddWastedTimeTeleportToStart(client);
		TimerDoTeleport(client, gF_StartOrigin[client], gF_StartAngles[client]);
		if (gB_AutoRestart[client]) {
			StartTimer(client);
		}
	}
	else {
		CS_RespawnPlayer(client);
	}
	CloseTeleportMenu(client);
}

void MakeCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Checkpoint_NotAlive");
	}
	else if (!g_MovementPlayer[client].onGround) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Checkpoint_Midair");
	}
	else {
		gI_CheckpointsSet[client]++;
		gF_LastCheckpointTime[client] = gF_CurrentTime[client];
		g_MovementPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
		g_MovementPlayer[client].GetEyeAngles(gF_CheckpointAngles[client]);
	}
	CloseTeleportMenu(client);
}

void TeleportToCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Teleport_NotAlive");
	}
	else if (gI_CheckpointsSet[client] == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Teleport_NoCheckpoint");
	}
	else if (gB_CurrentMapIsKZPro && gB_TimerRunning[client]) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Teleport_KZPro");
	}
	else {
		AddWastedTimeTeleportToCheckpoint(client);
		TimerDoTeleport(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client]);
	}
	CloseTeleportMenu(client);
}

void UndoTeleport(int client) {
	if (!IsPlayerAlive(client)) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Undo_NotAlive");
	}
	else if (gI_TeleportsUsed[client] < 1) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Undo_NoTeleport");
	}
	else if (!gB_LastTeleportOnGround[client]) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Undo_Midair");
	}
	else {
		AddWastedTimeUndoTeleport(client);
		TimerDoTeleport(client, gF_UndoOrigin[client], gF_UndoAngle[client]);
	}
	CloseTeleportMenu(client);
}

void TogglePause(int client) {
	if (!gB_TimerRunning[client]) {
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	}
	else if (gB_Paused[client]) {
		gB_Paused[client] = false;
		gB_HasResumedInThisRun[client] = true;
		gF_LastResumeTime[client] = gF_CurrentTime[client];
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	}
	else {
		if (gB_HasResumedInThisRun[client] && gF_CurrentTime[client] - gF_LastResumeTime[client] < PAUSE_COOLDOWN_AFTER_RESUMING) {
			CPrintToChat(client, "%t %t", "KZ_Tag", "Pause_JustResumed");
		}
		else if (!g_MovementPlayer[client].onGround) {
			CPrintToChat(client, "%t %t", "KZ_Tag", "Pause_Midair");
		}
		else {
			gB_Paused[client] = true;
			FreezePlayer(client);
		}
	}
	CloseTeleportMenu(client);
}



/*===============================  Wasted Time Tracking  ===============================*/

void AddWastedTimeTeleportToStart(int client) {
	float addedWastedTime = 0.0;
	addedWastedTime = gF_CurrentTime[client] - gF_WastedTime[client];
	gF_WastedTime[client] += addedWastedTime;
	gF_LastTeleportToStartWastedTime[client] = addedWastedTime;
	gF_LastTeleportToStartTime[client] = gF_CurrentTime[client];
}

void AddWastedTimeTeleportToCheckpoint(int client) {
	float addedWastedTime = 0.0;
	if (TeleportToStartWasLatestTeleport(client)) {
		addedWastedTime -= gF_LastTeleportToStartWastedTime[client];
	}
	if (UndoWasLatestTeleport(client)) {
		addedWastedTime -= gF_LastUndoWastedTime[client];
	}
	addedWastedTime += gF_CurrentTime[client] - FloatMax(gF_LastCheckpointTime[client], gF_LastGoCheckTime[client]);
	gF_WastedTime[client] += addedWastedTime;
	gF_LastGoCheckWastedTime[client] = addedWastedTime;
	gF_LastGoCheckTime[client] = gF_CurrentTime[client];
}

void AddWastedTimeUndoTeleport(int client) {
	float addedWastedTime = 0.0;
	if (TeleportToStartWasLatestTeleport(client)) {
		addedWastedTime -= gF_LastTeleportToStartWastedTime[client];
		addedWastedTime += gF_CurrentTime[client] - gF_LastTeleportToStartTime[client];
	}
	else if (UndoWasLatestTeleport(client)) {
		addedWastedTime -= gF_LastUndoWastedTime[client];
		addedWastedTime += gF_CurrentTime[client] - gF_LastUndoTime[client];
	}
	else {
		addedWastedTime -= gF_LastGoCheckWastedTime[client];
		addedWastedTime += gF_CurrentTime[client] - gF_LastGoCheckTime[client];
	}
	gF_WastedTime[client] += addedWastedTime;
	gF_LastUndoWastedTime[client] = addedWastedTime;
	gF_LastUndoTime[client] = gF_CurrentTime[client];
}

bool UndoWasLatestTeleport(int client) {
	return gF_LastUndoTime[client] > gF_LastGoCheckTime[client]
	 && gF_LastUndoTime[client] > gF_LastTeleportToStartTime[client];
}

bool TeleportToStartWasLatestTeleport(int client) {
	return gF_LastTeleportToStartTime[client] > gF_LastGoCheckTime[client]
	 && gF_LastTeleportToStartTime[client] > gF_LastUndoTime[client];
}



/*===============================  Other  ===============================*/

int GetCurrentRunType(int client) {
	// Returns 0 for PRO run
	if (gI_TeleportsUsed[client] == 0) {
		return 0;
	}
	// Returns 1 for TP run
	else {
		return 1;
	}
}

void PrintEndTimeString(int client) {
	if (GetCurrentRunType(client) == 0) {
		CPrintToChatAll("%t %t", "KZ_Tag", "BeatMapPro", 
			client, FormatTimeFloat(gF_CurrentTime[client]));
	}
	else {
		CPrintToChatAll("%t %t", "KZ_Tag", "BeatMap", 
			client, FormatTimeFloat(gF_CurrentTime[client]), gI_TeleportsUsed[client], FormatTimeFloat(gF_CurrentTime[client] - gF_WastedTime[client]));
	}
} 