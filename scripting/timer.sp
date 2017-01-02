/*	timer.sp

	Implementation of the climb timer and a checkpoint/teleport system.
*/

void TimerTick(int client) {
	if (gB_TimerRunning[client]) {
		gF_CurrentTime[client] = GetGameTime() - gF_StartTime[client];
	}
}

public void ButtonPress(const char[] name, int caller, int activator, float delay) {
	if (IsValidEntity(caller) || IsValidClient(activator)) {
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
		gB_TimerRunning[client] = true;
		gF_StartTime[client] = GetGameTime();
		// Reset checkpoints
		gI_CheckpointsSet[client] = 0;
		gI_TeleportsUsed[client] = 0;
		// Store start position
		gB_HasStartPosition[client] = true;
		g_MovementPlayer[client].GetOrigin(gF_StartOrigin[client]);
		GetClientEyeAngles(client, gF_StartAngles[client]);
	}
}

void EndTimer(int client) {
	if (gB_TimerRunning[client]) {
		char clientName[64];
		GetClientName(client, clientName, sizeof(clientName));
		gB_TimerRunning[client] = false;
		PrintToChatAll("[KZ] %s finished the map in %s (%s).", clientName, TimerFormatTime(gF_CurrentTime[client]), GetRunTypeString(client));
	}
}

void TimerSetupVariables(int client) {
	gB_TimerRunning[client] = false;
	gF_StartTime[client] = 0.0;
	gF_CurrentTime[client] = 0.0;
	gF_WastedTime[client] = 0.0;
	gB_HasStartPosition[client] = false;
}

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
		TeleportEntity(client, gF_StartOrigin[client], gF_StartAngles[client], view_as<float>( { 0.0, 0.0, -100.0 } ));
	}
	else {
		CS_RespawnPlayer(client);
	}
}

void MakeCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		ReplyToCommand(client, "[KZ] You must be alive to make a checkpoint.");
	}
	else if (!g_MovementPlayer[client].onGround) {
		ReplyToCommand(client, "[KZ] You can't make a checkpoint midair.");
	}
	else {
		gI_CheckpointsSet[client]++;
		g_MovementPlayer[client].GetOrigin(gF_CheckpointOrigin[client]);
		GetClientEyeAngles(client, gF_CheckpointAngles[client]);
		gF_CheckpointTime[client] = GetGameTime();
	}
}

void TeleportToCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		ReplyToCommand(client, "[KZ] You must be alive to teleport to a checkpoint.");
	}
	else if (gI_CheckpointsSet[client] == 0) {
		ReplyToCommand(client, "[KZ] You don't have a checkpoint set.");
	}
	else {
		gI_TeleportsUsed[client]++;
		if (g_MovementPlayer[client].onGround) {
			gB_CanUndo[client] = true;
			g_MovementPlayer[client].GetOrigin(gF_UndoOrigin[client]);
			GetClientEyeAngles(client, gF_UndoAngle[client]);
			gF_TeleportTime[client] = GetGameTime();
			gF_WastedTime[client] += GetGameTime() - MaxFloat(gF_CheckpointTime[client], gF_UndoTime[client]);
		}
		else {
			gB_CanUndo[client] = false;
		}
		TeleportEntity(client, gF_CheckpointOrigin[client], gF_CheckpointAngles[client], view_as<float>( { 0.0, 0.0, -100.0 } ));
	}
}

void UndoTeleport(int client) {
	if (!IsPlayerAlive(client)) {
		ReplyToCommand(client, "[KZ] You must be alive to undo a teleport.");
	}
	else if (gI_TeleportsUsed[client] == 0) {
		ReplyToCommand(client, "[KZ] You don't have a teleport to undo.");
	}
	else if (!gB_CanUndo[client]) {
		ReplyToCommand(client, "[KZ] You can't undo because you teleported midair.");
	}
	else {
		TeleportEntity(client, gF_UndoOrigin[client], gF_UndoAngle[client], view_as<float>( { 0.0, 0.0, -100.0 } ));
		gF_UndoTime[client] = GetGameTime();
		gF_WastedTime[client] += GetGameTime() - gF_TeleportTime[client];
	}
} 