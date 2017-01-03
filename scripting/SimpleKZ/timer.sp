/*	timer.sp

	Timer and checkpoint/teleport system.
*/

void TimerTick(int client) {
	if (IsPlayerAlive(client) && gB_TimerRunning[client] && !gB_Paused[client]) {
		gF_CurrentTime[client] += GetTickInterval();
	}
}

void TimerSetupVariables(int client) {
	gB_TimerRunning[client] = false;
	gB_Paused[client] = false;
	gB_HasStartPosition[client] = false;
	gI_CheckpointsSet[client] = 0;
	gI_TeleportsUsed[client] = 0;
}

void TimerDoTeleport(int client, float destination[3], float eyeAngles[3]) {
	// Store old variables here to avoid incorrect behaviour when teleporting to undo position
	float oldOrigin[3], oldAngles[3];
	g_MovementPlayer[client].GetOrigin(oldOrigin);
	GetClientEyeAngles(client, oldAngles);
	
	TeleportEntity(client, destination, eyeAngles, view_as<float>( { 0.0, 0.0, -50.0 } ));
	gI_TeleportsUsed[client]++;
	gF_TeleportTime[client] = gF_CurrentTime[client];
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
		gB_TimerRunning[client] = true;
		gB_Paused[client] = false;
		// Reset variables
		gF_CurrentTime[client] = 0.0;
		gI_CheckpointsSet[client] = 0;
		gI_TeleportsUsed[client] = 0;
		gF_CheckpointTime[client] = 0.0;
		gF_TeleportTime[client] = 0.0;
		gF_WastedTime[client] = 0.0;
		// Store start position
		gB_HasStartPosition[client] = true;
		g_MovementPlayer[client].GetOrigin(gF_StartOrigin[client]);
		GetClientEyeAngles(client, gF_StartAngles[client]);
		// Update teleport menu after variables have been reset
		gB_NeedToRefreshTeleportMenu[client] = true;
	}
}

void EndTimer(int client) {
	if (gB_TimerRunning[client]) {
		Call_SimpleKZ_OnTimerEnded(client);
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
		gF_CheckpointTime[client] = gF_CurrentTime[client];
		g_MovementPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
		GetClientEyeAngles(client, gF_CheckpointAngles[client]);
	}
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
		gF_WastedTime[client] += gF_CurrentTime[client] - FloatMax(gF_CheckpointTime[client], gF_TeleportTime[client]);
		TimerDoTeleport(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client]);
	}
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
}

void TogglePause(int client) {
	if (!gB_TimerRunning[client]) {
		return;
	}
	else if (gB_Paused[client]) {
		gB_Paused[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		PrintToChat(client, "[KZ] Resumed.");
	}
	else {
		if (!g_MovementPlayer[client].onGround) {
			PrintToChat(client, "[KZ] You can't pause in midair.");
		}
		else {
			gB_Paused[client] = true;
			g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
			SetEntityMoveType(client, MOVETYPE_NONE);
			PrintToChat(client, "[KZ] Paused.");
		}
	}
}



/*=====  Teleport Menu ======*/

void SetupTeleportMenu(int client) {
	gB_NeedToRefreshTeleportMenu[client] = true;
	gH_TeleportMenu[client] = CreateMenu(MenuHandler_Timer);
	TeleportMenuAddItems(client);
	SetMenuExitButton(gH_TeleportMenu[client], false);
	SetMenuOptionFlags(gH_TeleportMenu[client], MENUFLAG_NO_SOUND);
}

public int MenuHandler_Timer(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:MakeCheckpoint(param1);
			case 1:TeleportToCheckpoint(param1);
			case 2:UndoTeleport(param1);
			case 3:TeleportToStart(param1);
		}
		UpdateTeleportMenuItems(param1);
		gB_NeedToRefreshTeleportMenu[param1] = true;
	}
	else if (action == MenuAction_Cancel && param2 == MenuCancel_Interrupted) {
		gB_UsingOtherMenu[param1] = true;
		gB_NeedToRefreshTeleportMenu[param1] = true;
	}
}

void TeleportMenuAddItems(int client) {
	TeleportMenuAddItemCheckpoint(client);
	TeleportMenuAddItemTeleport(client);
	TeleportMenuAddItemUndo(client);
	TeleportMenuAddItemStart(client);
}

void UpdateTeleportMenuItems(int client) {
	RemoveAllMenuItems(gH_TeleportMenu[client]);
	TeleportMenuAddItems(client);
}

void TeleportMenuAddItemCheckpoint(int client) {
	AddMenuItem(gH_TeleportMenu[client], "sm_checkpoint", "Save");
}

void TeleportMenuAddItemTeleport(int client) {
	if (gI_CheckpointsSet[client] > 0) {
		AddMenuItem(gH_TeleportMenu[client], "sm_gocheck", "Back");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "sm_gocheck", "Back", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemUndo(int client) {
	if (gI_TeleportsUsed[client] > 0 && gB_LastTeleportOnGround[client]) {
		AddMenuItem(gH_TeleportMenu[client], "sm_undo", "Undo");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "sm_undo", "Undo", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemStart(int client) {
	if (gB_HasStartPosition[client]) {
		AddMenuItem(gH_TeleportMenu[client], "sm_start", "Start");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "sm_start", "Spawn");
	}
}

void UpdateTeleportMenu(int client) {
	if (gB_UsingOtherMenu[client] && GetClientMenu(client) == MenuSource_None) {
		gB_UsingOtherMenu[client] = false;
	}
	if (!gB_UsingOtherMenu[client] && IsPlayerAlive(client) && gB_UsingTeleportMenu[client] && gB_NeedToRefreshTeleportMenu[client]) {
		DisplayMenu(gH_TeleportMenu[client], client, MENU_TIME_FOREVER);
		gB_NeedToRefreshTeleportMenu[client] = false;
	}
} 