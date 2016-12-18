/*	conmands.sp
	
	Implements commands for player control over features of the plugin.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_menu", CommandToggleMenu, "[SimpleKZ] Toggles the visibility of the timer menu.");
	RegConsoleCmd("sm_checkpoint", CommandMakeCheckpoint, "[SimpleKZ] Set a checkpoint.");
	RegConsoleCmd("sm_gocheck", CommandTeleportToCheckpoint, "[SimpleKZ] Teleport to the checkpoint.");
	RegConsoleCmd("sm_undo", CommandUndoTeleport, "[SimpleKZ] Undo teleport to checkpoint.");
	RegConsoleCmd("sm_start", CommandTeleportToStart, "[SimpleKZ] Teleports you to the start of the map.");
	RegConsoleCmd("sm_stopsound", CommandStopsound, "[SimpleKZ] Stops all sounds e.g. map soundscapes (music).");
	RegConsoleCmd("sm_hide", CommandHide, "[SimpleKZ] Hides other players.");
	RegConsoleCmd("+noclip", CommandEnableNoclip, "[SimpleKZ] Noclip on.");
	RegConsoleCmd("-noclip", CommandDisableNoclip, "[SimpleKZ] Noclip off.");
}


// Command Handlers

public Action CommandToggleMenu(client, args) {
	if (IsValidClient(client)) {
		if (g_clientUsingTeleportMenu[client]) {
			g_clientUsingTeleportMenu[client] = false;
			PrintToChat(client, "[KZ] Teleport menu disabled.");
		}
		else {
			g_clientUsingTeleportMenu[client] = true;
			PrintToChat(client, "[KZ] Teleport menu enabled.");
		}
	}
	return Plugin_Handled;
}

public Action CommandMakeCheckpoint(client, args) {
	if (IsValidClient(client)) {
		MakeCheckpoint(client);
	}
	return Plugin_Handled;
}

public Action CommandTeleportToCheckpoint(client, args) {
	if (IsValidClient(client)) {
		TeleportToCheckpoint(client);
	}
	return Plugin_Handled;
}

public Action CommandUndoTeleport(client, args) {
	if (IsValidClient(client)) {
		UndoTeleport(client);
	}
	return Plugin_Handled;
}

public Action CommandTeleportToStart(client, args) {
	if (IsValidClient(client)) {
		TeleportToStart(client);
	}
	return Plugin_Handled;
}

public Action CommandStopsound(client, args) {
	if (IsValidClient(client)) {
		ClientCommand(client, "snd_playsounds Music.StopAllExceptMusic");
	}
	return Plugin_Handled;
}

public Action CommandHide(client, args) {
	if (IsValidClient(client)) {
		if (g_clientHidingPlayers[client]) {
			g_clientHidingPlayers[client] = false;
			PrintToChat(client, "[KZ] You are now showing other players.");
		}
		else {
			g_clientHidingPlayers[client] = true;
			PrintToChat(client, "[KZ] You are now hiding other players.");
		}
	}
	return Plugin_Handled;
}

public Action CommandEnableNoclip(client, args) {
	if (IsValidClient(client)) {
		if (g_clientTimerRunning[client])
		{
			g_clientTimerRunning[client] = false;
			PrintToChat(client, "[KZ] Time stopped. Reason: +noclip used.");
		}
		SetEntityMoveType(client, MOVETYPE_NOCLIP);
	}
	return Plugin_Handled;
}

public Action CommandDisableNoclip(client, args) {
	if (IsValidClient(client)) {
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
	return Plugin_Handled;
} 