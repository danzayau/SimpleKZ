/*	timer.sp

*/


// Functions

void TimerTick(int client) {
	if (g_clientTimerRunning[client]) {
		g_clientCurrentTime[client] = GetGameTime() - g_clientStartTime[client];
	}
}

public ButtonPress(const char[] name, int caller, int activator, float delay) {
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
	if ((GetEntityFlags(client) & FL_ONGROUND) && (GetEntityMoveType(client) == MOVETYPE_WALK)) {
		g_clientTimerRunning[client] = true;
		g_clientStartTime[client] = GetGameTime();
		// Reset checkpoints
		TimerResetClientTeleportVars(client);
		// Store start position
		g_clientHasStartPosition[client] = true;
		GetClientAbsOrigin(client, g_clientStartOrigin[client]);
		GetClientEyeAngles(client, g_clientStartAngles[client]);
	}
}

void EndTimer(int client) {
	if (g_clientTimerRunning[client]) {
		char clientName[64];
		GetClientName(client, clientName, sizeof(clientName));
		g_clientTimerRunning[client] = false;
		PrintToChatAll("[KZ] %s finished the map in %s (%s).", clientName, TimerFormatTime(g_clientCurrentTime[client]), GetRunTypeString(client));
	}
}

void TimerResetClientVariables(int client) {
	g_clientTimerRunning[client] = false;
	g_clientStartTime[client] = 0.0;
	g_clientCurrentTime[client] = 0.0;
	g_clientHasStartPosition[client] = false;
	TimerResetClientTeleportVars(client);
	TimerResetClientMenuVars(client);
}

void TimerResetClientTeleportVars(int client) {
	g_clientCheckpointsSet[client] = 0;
	g_clientTeleportsUsed[client] = 0;
}

void TeleportToStart(int client) {
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		ChangeClientTeam(client, CS_TEAM_CT);
	}
	if (g_clientHasStartPosition[client]) {
		// Respawn the player if necessary
		if (!IsPlayerAlive(client)) {
			CS_RespawnPlayer(client);
		}
		TeleportEntity(client, g_clientStartOrigin[client], g_clientStartAngles[client], Float: { 0.0, 0.0, -100.0 } );
	}
	else {
		CS_RespawnPlayer(client);
	}
}

void MakeCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		ReplyToCommand(client, "[KZ] You must be alive to make a checkpoint.");
	}
	// Check if on ground
	else if (GetEntityFlags(client) & FL_ONGROUND) {
		g_clientCheckpointsSet[client]++;
		GetClientAbsOrigin(client, g_clientCheckpointOrigin[client]);
		GetClientEyeAngles(client, g_clientCheckpointAngles[client]);
		EmitSoundToClient(client, "buttons/button15.wav", client);
	}
	else {
		PrintToChat(client, "[KZ] You can't make a checkpoint midair.");
	}
}

void TeleportToCheckpoint(int client) {
	if (!IsPlayerAlive(client)) {
		ReplyToCommand(client, "[KZ] You must be alive to teleport to a checkpoint.");
	}
	else if (g_clientCheckpointsSet[client] > 0) {
		g_clientTeleportsUsed[client]++;
		if (GetEntityFlags(client) & FL_ONGROUND) {
			g_clientCanUndo[client] = true;
			GetClientAbsOrigin(client, g_clientUndoOrigin[client]);
			GetClientEyeAngles(client, g_clientUndoAngle[client]);
		}
		else {
			g_clientCanUndo[client] = false;
		}
		TeleportEntity(client, g_clientCheckpointOrigin[client], g_clientCheckpointAngles[client], Float: { 0.0, 0.0, -100.0 } );
	}
}

void UndoTeleport(int client) {
	if (!IsPlayerAlive(client)) {
		ReplyToCommand(client, "[KZ] You must be alive to undo a teleport.");
	}
	else if (g_clientTeleportsUsed[client] > 0) {
		if (g_clientCanUndo[client]) {
			TeleportEntity(client, g_clientUndoOrigin[client], g_clientUndoAngle[client], Float: { 0.0, 0.0, -100.0 } );
		}
		else {
			PrintToChat(client, "[KZ] You can't undo because you teleported midair.");
			EmitSoundToClient(client, "buttons/button10.wav", client);
		}
	}
} 