/*	timer.sp

	Timer and checkpoint/teleport system.
*/


/*===============================  General  ===============================*/

void TimerTick(int client) {
	if (IsPlayerAlive(client) && gB_TimerRunning[client] && !gB_Paused[client]) {
		gF_CurrentTime[client] += GetTickInterval();
	}
}

void TimerSetup(int client) {
	gB_TimerRunning[client] = false;
	gB_HasStartedThisMap[client] = false;
	TimerReset(client);
}

void TimerReset(int client) {
	gF_CurrentTime[client] = 0.0;
	gB_Paused[client] = false;
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
	
	TimerReset(client);
	g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	gB_TimerRunning[client] = true;
	gI_CurrentCourse[client] = course;
	gB_HasStartedThisMap[client] = true;
	g_MovementPlayer[client].GetOrigin(gF_StartOrigin[client]);
	g_MovementPlayer[client].GetEyeAngles(gF_StartAngles[client]);
	SplitsReset(client);
	EmitSoundToClient(client, "buttons/button9.wav");
	EmitSoundToClientSpectators(client, "buttons/button9.wav");
	Call_SimpleKZ_OnTimerStart(client);
	CloseTeleportMenu(client);
}

void TimerEnd(int client, int course) {
	if (gB_TimerRunning[client] && course == gI_CurrentCourse[client]) {
		gB_TimerRunning[client] = false;
		PrintEndTimeString(client);
		if (gB_SlayOnEnd[client]) {
			CreateTimer(3.0, SlayPlayer, client);
		}
		EmitSoundToClient(client, "buttons/bell1.wav");
		EmitSoundToClientSpectators(client, "buttons/bell1.wav");
		Call_SimpleKZ_OnTimerEnd(client);
		CloseTeleportMenu(client);
	}
}

void TimerForceStop(int client) {
	if (gB_TimerRunning[client]) {
		EmitSoundToClient(client, "buttons/button18.wav");
		EmitSoundToClientSpectators(client, "buttons/button18.wav");
		gB_TimerRunning[client] = false;
		Call_SimpleKZ_OnTimerForceStop(client);
		CloseTeleportMenu(client);
	}
}

void TimerForceStopAll() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsValidClient(client)) {
			TimerForceStop(client);
		}
	}
}



/*===============================  Start and End Buttons  ===============================*/

public void OnButtonPress(const char[] name, int caller, int activator, float delay) {
	if (!IsValidEntity(caller) || !IsValidClient(activator)) {
		return;
	}
	
	char tempString[32];
	// Get the class name of the activator
	GetEdictClassname(activator, tempString, sizeof(tempString));
	if (StrEqual(tempString, "player")) {
		// Get the name of the pressed func_button
		GetEntPropString(caller, Prop_Data, "m_iName", tempString, sizeof(tempString));
		// Check if button entity name is something we want to do something with
		if (StrEqual("climb_startbutton", tempString, false)) {
			g_MovementPlayer[activator].GetOrigin(gF_StartButtonOrigin[activator]);
			TimerStart(activator, 0);
		}
		else if (StrEqual("climb_endbutton", tempString, false)) {
			g_MovementPlayer[activator].GetOrigin(gF_EndButtonOrigin[activator]);
			TimerEnd(activator, 0);
		}
		else if (MatchRegex(gRE_BonusStartButton, tempString) > 0) {
			GetRegexSubString(gRE_BonusStartButton, 1, tempString, sizeof(tempString));
			int bonus = StringToInt(tempString);
			if (bonus > 0) {
				TimerStart(activator, bonus);
			}
		}
		else if (MatchRegex(gRE_BonusEndButton, tempString) > 0) {
			GetRegexSubString(gRE_BonusEndButton, 1, tempString, sizeof(tempString));
			int bonus = StringToInt(tempString);
			if (bonus > 0) {
				TimerEnd(activator, bonus);
			}
		}
	}
}

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
		if (gB_AutoRestart[client]) {
			TimerStart(client, gI_LastCourseStarted[client]);
		}
	}
	else {
		CS_RespawnPlayer(client);
	}
	CloseTeleportMenu(client);
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
	}
	CloseTeleportMenu(client);
}

void TeleportToCheckpoint(int client) {
	if (!IsPlayerAlive(client) || gI_CheckpointCount[client] == 0) {
		return;
	}
	else if (gB_CurrentMapIsKZPro && gB_TimerRunning[client]) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Teleport (kzpro_)");
	}
	else {
		AddWastedTimeTeleportToCheckpoint(client);
		TimerDoTeleport(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client]);
	}
	CloseTeleportMenu(client);
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
	}
	CloseTeleportMenu(client);
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
	else if (gB_TimerRunning[client] && !g_MovementPlayer[client].onGround) {
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
	CloseTeleportMenu(client);
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
	CloseTeleportMenu(client);
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
		switch (GetCurrentRunType(client)) {
			case RunType_Normal: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map", 
					client, SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SimpleKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StyleChatPhrases[g_Style[client]]);
			}
			case RunType_Pro: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map (Pro)", 
					client, SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StyleChatPhrases[g_Style[client]]);
			}
		}
	}
	else {
		switch (GetCurrentRunType(client)) {
			case RunType_Normal: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus", 
					client, gI_CurrentCourse[client], SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SimpleKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StyleChatPhrases[g_Style[client]]);
			}
			case RunType_Pro: {
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus (Pro)", 
					client, gI_CurrentCourse[client], SimpleKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StyleChatPhrases[g_Style[client]]);
			}
		}
	}
} 