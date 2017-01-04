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
	gB_HasStartPosition[client] = false;
	TimerRestart(client);
}

void ForceStopTimer(int client) {
	gB_TimerRunning[client] = false;
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
	gF_LastTeleportTime[client] = 0.0;
	gF_WastedTime[client] = 0.0;
	gB_HasSavedPosition[client] = false;
}

void TimerDoTeleport(int client, float destination[3], float eyeAngles[3]) {
	// Store old variables here to avoid incorrect behaviour when teleporting to undo position
	float oldOrigin[3], oldAngles[3];
	g_MovementPlayer[client].GetOrigin(oldOrigin);
	GetClientEyeAngles(client, oldAngles);
	
	TeleportEntity(client, destination, eyeAngles, view_as<float>( { 0.0, 0.0, -50.0 } ));
	gI_TeleportsUsed[client]++;
	gF_LastTeleportTime[client] = gF_CurrentTime[client];
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



/*=====  Start and End Buttons  ======*/

public void OnButtonPress(const char[] name, int caller, int activator, float delay) {
	if (IsValidEntity(caller) && IsValidClient(activator)) {
		char tempString[64];
		// Get the class name of the activator
		GetEdictClassname(activator, tempString, sizeof(tempString));
		if (StrEqual(tempString, "player")) {
			// Get the name of the pressed func_button
			GetEntPropString(caller, Prop_Data, "m_iName", tempString, sizeof(tempString));
			// Check if button entity name is something we want to do something with
			if (StrEqual(tempString, "climb_startbutton")) {
				StartTimer(activator);
			}
			else if (StrEqual(tempString, "climb_endbutton")) {
				EndTimer(activator);
			}
		}
	}
}

void StartTimer(int client) {
	// Have to be on ground and not noclipping to start the timer
	if (g_MovementPlayer[client].onGround && !g_MovementPlayer[client].noclipping) {
		Call_SimpleKZ_OnTimerStarted(client);
		EmitSoundToClient(client, "buttons/button9.wav");
		TimerRestart(client);
		gB_TimerRunning[client] = true;
		gB_HasStartPosition[client] = true;
		g_MovementPlayer[client].GetOrigin(gF_StartOrigin[client]);
		GetClientEyeAngles(client, gF_StartAngles[client]);
	}
	CloseTeleportMenu(client);
}

void EndTimer(int client) {
	if (gB_TimerRunning[client]) {
		Call_SimpleKZ_OnTimerEnded(client);
		EmitSoundToClient(client, "buttons/bell1.wav");
		gB_TimerRunning[client] = false;
		PrintToChatAll("%s", GetEndTimeString(client));
	}
}



/*=====  Timer Commands ======*/

void TeleportToStart(int client) {
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		ChangeClientTeam(client, CS_TEAM_CT);
	}
	if (gB_HasStartPosition[client]) {
		// Respawn the player if necessary
		if (!IsPlayerAlive(client)) {
			CS_RespawnPlayer(client);
		}
		TimerDoTeleport(client, gF_StartOrigin[client], gF_StartAngles[client]);
	}
	else {
		CS_RespawnPlayer(client);
	}
	CloseTeleportMenu(client);
}

void MakeCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		PrintToChat(client, "[KZ] You must be alive to make a checkpoint.");
	}
	else if (!g_MovementPlayer[client].onGround) {
		PrintToChat(client, "[KZ] You can't make a checkpoint midair.");
	}
	else {
		gI_CheckpointsSet[client]++;
		gF_LastCheckpointTime[client] = gF_CurrentTime[client];
		g_MovementPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
		GetClientEyeAngles(client, gF_CheckpointAngles[client]);
	}
	CloseTeleportMenu(client);
}

void TeleportToCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		PrintToChat(client, "[KZ] You must be alive to teleport to a checkpoint.");
	}
	else if (gI_CheckpointsSet[client] == 0) {
		PrintToChat(client, "[KZ] You don't have a checkpoint set.");
	}
	else {
		// Updated wasted time before performing teleport
		gF_WastedTime[client] += gF_CurrentTime[client] - FloatMax(gF_LastCheckpointTime[client], gF_LastTeleportTime[client]);
		TimerDoTeleport(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client]);
	}
	CloseTeleportMenu(client);
}

void UndoTeleport(int client) {
	if (!IsPlayerAlive(client)) {
		PrintToChat(client, "[KZ] You must be alive to undo a teleport.");
	}
	else if (gI_TeleportsUsed[client] < 1) {
		PrintToChat(client, "[KZ] You don't have a teleport to undo.");
	}
	else if (!gB_LastTeleportOnGround[client]) {
		PrintToChat(client, "[KZ] You can't undo because you teleported midair.");
	}
	else {
		TimerDoTeleport(client, gF_UndoOrigin[client], gF_UndoAngle[client]);
	}
	CloseTeleportMenu(client);
}

void TogglePause(int client) {
	if (!gB_TimerRunning[client]) {
		return;
	}
	else if (gB_Paused[client]) {
		gB_Paused[client] = false;
		gB_HasResumedInThisRun[client] = true;
		gF_LastResumeTime[client] = gF_CurrentTime[client];
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	else {
		if (gB_HasResumedInThisRun[client] && gF_CurrentTime[client] - gF_LastResumeTime[client] < PAUSE_COOLDOWN_AFTER_RESUMING) {
			PrintToChat(client, "[KZ] You can't pause because you just resumed.");
		}
		else if (!g_MovementPlayer[client].onGround) {
			PrintToChat(client, "[KZ] You can't pause in midair.");
		}
		else {
			gB_Paused[client] = true;
			FreezePlayer(client);
		}
	}
	CloseTeleportMenu(client);
}



/*=====  Teleport Menu ======*/

void SetupTeleportMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		SetupTeleportMenu(client);
	}
}

void SetupTeleportMenu(int client) {
	gH_TeleportMenu[client] = CreateMenu(MenuHandler_Timer);
	SetMenuExitButton(gH_TeleportMenu[client], false);
	SetMenuOptionFlags(gH_TeleportMenu[client], MENUFLAG_NO_SOUND);
}

void UpdateTeleportMenu(int client) {
	if (GetClientMenu(client) == MenuSource_None && gB_UsingTeleportMenu[client] && !gB_TeleportMenuIsShowing[client]) {
		UpdateTeleportMenuItems(client);
		DisplayMenu(gH_TeleportMenu[client], client, MENU_TIME_FOREVER);
		gB_TeleportMenuIsShowing[client] = true;
	}
}

public int MenuHandler_Timer(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (IsPlayerAlive(param1)) {
			switch (param2) {
				case 0:MakeCheckpoint(param1);
				case 1:TeleportToCheckpoint(param1);
				case 2:UndoTeleport(param1);
				case 3:TogglePause(param1);
				case 4:TeleportToStart(param1);
			}
		}
		else {
			switch (param2) {
				case 0:JoinTeam(param1, CS_TEAM_CT);
			}
		}
	}
	else if (action == MenuAction_Cancel) {
		gB_TeleportMenuIsShowing[param1] = false;
	}
}

void CloseTeleportMenu(int client) {
	if (gB_TeleportMenuIsShowing[client]) {
		CancelClientMenu(client);
		gB_TeleportMenuIsShowing[client] = false;
	}
}

void TeleportMenuAddItems(int client) {
	if (IsPlayerAlive(client)) {
		SetMenuTitle(gH_TeleportMenu[client], "");
		TeleportMenuAddItemCheckpoint(client);
		TeleportMenuAddItemTeleport(client);
		TeleportMenuAddItemUndo(client);
		TeleportMenuAddItemPause(client);
		TeleportMenuAddItemStart(client);
	}
	else {
		if (gB_TimerRunning[client]) {
			SetMenuTitle(gH_TeleportMenu[client], "PAUSED\n%s %s", 
				GetRunTypeString(client), 
				TimerFormatTime(gF_CurrentTime[client]));
		}
		TeleportMenuAddItemRejoin(client);
	}
}

void UpdateTeleportMenuItems(int client) {
	RemoveAllMenuItems(gH_TeleportMenu[client]);
	TeleportMenuAddItems(client);
}

void TeleportMenuAddItemCheckpoint(int client) {
	AddMenuItem(gH_TeleportMenu[client], "Make a Checkpoint", "Save");
}

void TeleportMenuAddItemTeleport(int client) {
	if (gI_CheckpointsSet[client] > 0) {
		AddMenuItem(gH_TeleportMenu[client], "Go Back to Checkpoint", "Back");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "Can't Go Back to Checkpoint", "Back", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemUndo(int client) {
	if (gI_TeleportsUsed[client] > 0 && gB_LastTeleportOnGround[client]) {
		AddMenuItem(gH_TeleportMenu[client], "Undo", "Undo");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "Can't Undo", "Undo", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemPause(int client) {
	if (gB_TimerRunning[client]) {
		if (!gB_Paused[client]) {
			AddMenuItem(gH_TeleportMenu[client], "Pause Timer", "Pause");
		}
		else {
			AddMenuItem(gH_TeleportMenu[client], "Resume Timer", "Resume");
		}
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "Can't Pause", "Pause", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemStart(int client) {
	if (gB_HasStartPosition[client]) {
		AddMenuItem(gH_TeleportMenu[client], "Teleport to Start", "Start");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "Teleport to Spawn", "Spawn");
	}
}

void TeleportMenuAddItemRejoin(int client) {
	AddMenuItem(gH_TeleportMenu[client], "Leave Spectators", "Rejoin");
} 