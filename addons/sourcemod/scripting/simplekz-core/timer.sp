/*	timer.sp

	Timer and checkpoint/teleport system.
*/


/*===============================  General  ===============================*/

void UpdateTimer(int client) {
	if (IsPlayerAlive(client) && gB_TimerRunning[client] && !gB_Paused[client]) {
		gF_CurrentTime[client] += GetTickInterval();
	}
}

void TimerSetup(int client) {
	gB_TimerRunning[client] = false;
	gB_Paused[client] = false;
	gB_HasStartedThisMap[client] = false;
	TimerReset(client);
}

void TimerReset(int client) {
	// Reset all stored variables
	gF_CurrentTime[client] = 0.0;
	gF_LastResumeTime[client] = 0.0;
	gB_HasResumedInThisRun[client] = false;
	gI_CheckpointCount[client] = 0;
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
}

void TimerStart(int client, int course) {
	// Have to be on ground and not noclipping to start the timer
	if (!g_MovementPlayer[client].onGround || g_MovementPlayer[client].noclipping) {
		return;
	}
	
	Resume(client);
	TimerReset(client);
	gB_TimerRunning[client] = true;
	gI_CurrentCourse[client] = course;
	gB_HasStartedThisMap[client] = true;
	g_MovementPlayer[client].GetOrigin(gF_StartOrigin[client]);
	g_MovementPlayer[client].GetEyeAngles(gF_StartAngles[client]);
	PlayTimerStartSound(client);
	Call_SimpleKZ_OnTimerStart(client);
	CloseTPMenu(client);
}

void TimerEnd(int client, int course) {
	if (gB_TimerRunning[client] && course == gI_CurrentCourse[client]) {
		gB_TimerRunning[client] = false;
		PrintEndTimeString(client);
		if (g_SlayOnEnd[client] == KZSlayOnEnd_Enabled) {
			CreateTimer(3.0, SlayPlayer, client);
		}
		PlayTimerEndSound(client);
		Call_SimpleKZ_OnTimerEnd(client);
		CloseTPMenu(client);
	}
}

bool TimerForceStop(int client) {
	if (gB_TimerRunning[client]) {
		PlayTimerForceStopSound(client);
		gB_TimerRunning[client] = false;
		Call_SimpleKZ_OnTimerForceStop(client);
		CloseTPMenu(client);
		return true;
	}
	return false;
}

void TimerForceStopAll() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsValidClient(client)) {
			TimerForceStop(client);
		}
	}
}



/*===============================  Start and End Buttons  ===============================*/

void CheckForTimerButtonPress(int client) {
	// If just pressed +use button
	if (!(gI_OldButtons[client] & IN_USE) && GetClientButtons(client) & IN_USE) {
		float origin[3];
		g_MovementPlayer[client].GetOrigin(origin);
		// If didnt just start time
		if (!(gB_TimerRunning[client] && gF_CurrentTime[client] < 0.1)
			 && gB_HasStartedThisMap[client] && GetVectorDistance(origin, gF_StartButtonOrigin[client]) <= DISTANCE_BUTTON_PRESS_CHECK) {
			TimerStart(client, gI_LastCourseStarted[client]);
		}
		else if (gB_HasEndedThisMap[client] && GetVectorDistance(origin, gF_EndButtonOrigin[client]) <= DISTANCE_BUTTON_PRESS_CHECK) {
			TimerEnd(client, gI_LastCourseEnded[client]);
		}
	}
	gI_OldButtons[client] = GetClientButtons(client);
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
		if (g_AutoRestart[client] == KZAutoRestart_Enabled) {
			TimerStart(client, gI_LastCourseStarted[client]);
		}
	}
	else {
		CS_RespawnPlayer(client);
	}
	CloseTPMenu(client);
}

void MakeCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Dead)");
	}
	else if (!g_MovementPlayer[client].onGround) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Midair)");
	}
	else if (JustTouchedBhopBlock(client)) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Checkpoint (Just Landed)");
	}
	else {
		gI_CheckpointCount[client]++;
		gF_LastCheckpointTime[client] = gF_CurrentTime[client];
		g_MovementPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
		g_MovementPlayer[client].GetEyeAngles(gF_CheckpointAngles[client]);
		if (g_CheckpointMessages[client] == KZCheckpointMessages_Enabled) {
			CPrintToChat(client, "%t %t", "KZ Prefix", "Make Checkpoint");
		}
		if (g_CheckpointSounds[client] == KZCheckpointSounds_Enabled) {
			EmitSoundToClient(client, SOUND_TELEPORT);
		}
	}
	CloseTPMenu(client);
}

void TeleportToCheckpoint(int client) {
	if (!IsPlayerAlive(client) || gI_CheckpointCount[client] == 0) {
		return;
	}
	else if (gB_CurrentMapIsKZPro && gB_TimerRunning[client]) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Teleport (Map)");
	}
	else {
		AddWastedTimeTeleportToCheckpoint(client);
		TimerDoTeleport(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client]);
		if (g_TeleportSounds[client] == KZTeleportSounds_Enabled) {
			EmitSoundToClient(client, SOUND_TELEPORT);
		}
	}
	CloseTPMenu(client);
}

void UndoTeleport(int client) {
	if (!IsPlayerAlive(client) || gI_TeleportsUsed[client] < 1) {
		return;
	}
	else if (!gB_LastTeleportOnGround[client]) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Undo (TP Was Midair)");
	}
	else {
		AddWastedTimeUndoTeleport(client);
		TimerDoTeleport(client, gF_UndoOrigin[client], gF_UndoAngle[client]);
		if (g_TeleportSounds[client]) {
			EmitSoundToClient(client, SOUND_TELEPORT);
		}
	}
	CloseTPMenu(client);
}

void Pause(int client) {
	if (gB_Paused[client]) {
		return;
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		JoinTeam(client, CS_TEAM_CT);
	}
	else if (gB_TimerRunning[client] && gB_HasResumedInThisRun[client] && gF_CurrentTime[client] - gF_LastResumeTime[client] < TIME_PAUSE_COOLDOWN) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Just Resumed)");
	}
	// Can't pause in the air if timer is running and player is moving
	else if (gB_TimerRunning[client] && !g_MovementPlayer[client].onGround
		 && !(g_MovementPlayer[client].speed == 0 && g_MovementPlayer[client].verticalVelocity == 0)) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Midair)");
	}
	else {
		gB_Paused[client] = true;
		if (gB_TimerRunning[client]) {
			g_MovementPlayer[client].GetEyeAngles(gF_PauseAngles[client]);
		}
		FreezePlayer(client);
		Call_SimpleKZ_OnPlayerPause(client);
	}
	CloseTPMenu(client);
}

void Resume(int client) {
	if (!gB_Paused[client]) {
		return;
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		JoinTeam(client, CS_TEAM_CT);
	}
	else {
		gB_Paused[client] = false;
		if (gB_TimerRunning[client]) {
			gB_HasResumedInThisRun[client] = true;
			gF_LastResumeTime[client] = gF_CurrentTime[client];
			g_MovementPlayer[client].SetEyeAngles(gF_PauseAngles[client]);
		}
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
		Call_SimpleKZ_OnPlayerResume(client);
	}
	CloseTPMenu(client);
}

void TogglePause(int client) {
	if (gB_Paused[client]) {
		Resume(client);
	}
	else {
		Pause(client);
	}
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

void TimerDoTeleport(int client, float destination[3], float eyeAngles[3]) {
	// Store old variables here to avoid incorrect behaviour when teleporting to undo position
	float oldOrigin[3], oldAngles[3];
	g_MovementPlayer[client].GetOrigin(oldOrigin);
	g_MovementPlayer[client].GetEyeAngles(oldAngles);
	
	TeleportEntity(client, destination, eyeAngles, view_as<float>( { 0.0, 0.0, -50.0 } ));
	CreateTimer(0.0, ZeroVelocity, client); // Prevent booster exploits
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
	
	Call_SimpleKZ_OnPlayerTeleport(client);
}

void PrintEndTimeString(int client) {
	if (gI_CurrentCourse[client] == 0) {
		switch (GetCurrentTimeType(client)) {
			case KZTimeType_Normal: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map", 
					client, SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SimpleKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
			case KZTimeType_Pro: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map (Pro)", 
					client, SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
		}
	}
	else {
		switch (GetCurrentTimeType(client)) {
			case KZTimeType_Normal: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus", 
					client, gI_CurrentCourse[client], SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SimpleKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
			case KZTimeType_Pro: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus (Pro)", 
					client, gI_CurrentCourse[client], SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
		}
	}
}

void PlayTimerStartSound(int client) {
	switch (g_Style[client]) {
		case KZStyle_Standard: {
			EmitSoundToClient(client, STYLE_DEFAULT_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_DEFAULT_SOUND_START);
		}
		case KZStyle_Legacy: {
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_START);
		}
	}
}

void PlayTimerEndSound(int client) {
	switch (g_Style[client]) {
		case KZStyle_Standard: {
			EmitSoundToClient(client, STYLE_DEFAULT_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_DEFAULT_SOUND_END);
		}
		case KZStyle_Legacy: {
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_END);
		}
	}
}

void PlayTimerForceStopSound(int client) {
	EmitSoundToClient(client, SOUND_TIMER_FORCE_STOP);
	EmitSoundToClientSpectators(client, SOUND_TIMER_FORCE_STOP);
} 