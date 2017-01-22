/*	commands.sp
	
	Commands for player use.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_menu", CommandToggleMenu, "[KZ] Toggles the visibility of the teleport menu.");
	RegConsoleCmd("sm_checkpoint", CommandMakeCheckpoint, "[KZ] Save a checkpoint.");
	RegConsoleCmd("sm_gocheck", CommandTeleportToCheckpoint, "[KZ] Teleport to the checkpoint.");
	RegConsoleCmd("sm_undo", CommandUndoTeleport, "[KZ] Undo teleport to checkpoint.");
	RegConsoleCmd("sm_start", CommandTeleportToStart, "[KZ] Teleports you to the start of the map.");
	RegConsoleCmd("sm_r", CommandTeleportToStart, "[KZ] Teleports you to the start of the map.");
	RegConsoleCmd("sm_pause", CommandTogglePause, "[KZ] Toggles pausing your timer and stopping you in your position.");
	RegConsoleCmd("sm_stop", CommandStopTimer, "[KZ] Stops your timer.");
	RegConsoleCmd("sm_stopsound", CommandStopsound, "[KZ] Stops all sounds e.g. map soundscapes (music).");
	RegConsoleCmd("sm_hide", CommandHide, "[KZ] Hides other players.");
	RegConsoleCmd("sm_goto", CommandGoto, "[KZ] Teleport to another player.");
	RegConsoleCmd("sm_spec", CommandSpec, "[KZ] Spectate another player.");
	RegConsoleCmd("sm_speed", CommandToggleInfoPanel, "[KZ] Toggle visibility of the centre information panel.");
	RegConsoleCmd("sm_hideweapon", CommandToggleHideWeapon, "[KZ] Toggle visibility of your weapon.");
	RegConsoleCmd("sm_keys", CommandToggleShowKeys, "[KZ] Toggles showing your key presses to yourself.");
	RegConsoleCmd("sm_measure", CommandMeasureMenu, "[KZ] Open the measure menu.");
	RegConsoleCmd("sm_pistol", CommandPistolMenu, "[KZ] Open the pistol selection menu.");
	RegConsoleCmd("sm_noclip", CommandToggleNoclip, "[KZ] Toggle noclip.");
	RegConsoleCmd("+noclip", CommandEnableNoclip, "[KZ] Noclip on.");
	RegConsoleCmd("-noclip", CommandDisableNoclip, "[KZ] Noclip off.");
	
	// Database commands
	RegConsoleCmd("sm_maprank", CommandMapRank, "[KZ] Prints map time and rank to chat. Usage: !maprank <player> <map>");
	RegConsoleCmd("sm_pb", CommandMapRank, "[KZ] Prints map time and rank to chat. Usage: !maprank <player> <map>");
	RegConsoleCmd("sm_maprecord", CommandMapRecord, "[KZ] Prints map record times to chat. Usage: !maprecord <map>");
	RegConsoleCmd("sm_wr", CommandMapRecord, "[KZ] Prints map record times to chat. Usage: !maprecord <map>");
	RegConsoleCmd("sm_maptop", CommandMapTop, "[KZ] Opens a menu showing the top times of a map. Usage !maptop <map>");
}



/*===============================  Command Handlers  ===============================*/

public Action CommandToggleMenu(int client, int args) {
	if (gB_ShowingTeleportMenu[client]) {
		gB_ShowingTeleportMenu[client] = false;
		CloseTeleportMenu(client);
		PrintToChat(client, "[\x06KZ\x01] Your teleport menu has been disabled.");
	}
	else {
		gB_ShowingTeleportMenu[client] = true;
		PrintToChat(client, "[\x06KZ\x01] Your teleport menu has been enabled.");
	}
	return Plugin_Handled;
}

public Action CommandMakeCheckpoint(int client, int args) {
	MakeCheckpoint(client);
	return Plugin_Handled;
}

public Action CommandTeleportToCheckpoint(int client, int args) {
	TeleportToCheckpoint(client);
	return Plugin_Handled;
}

public Action CommandUndoTeleport(int client, int args) {
	UndoTeleport(client);
	return Plugin_Handled;
}

public Action CommandTeleportToStart(int client, int args) {
	TeleportToStart(client);
	return Plugin_Handled;
}

public Action CommandTogglePause(int client, int args) {
	TogglePause(client);
	return Plugin_Handled;
}

public Action CommandStopTimer(int client, int args) {
	ForceStopTimer(client);
	PrintToChat(client, "[\x06KZ\x01] You have stopped your timer.");
	return Plugin_Handled;
}

public Action CommandStopsound(int client, int args) {
	ClientCommand(client, "snd_playsounds Music.StopAllExceptMusic");
	PrintToChat(client, "[\x06KZ\x01] You have stopped all sounds.");
	return Plugin_Handled;
}

public Action CommandHide(int client, int args) {
	if (!gB_ShowingPlayers[client]) {
		gB_ShowingPlayers[client] = true;
		PrintToChat(client, "[\x06KZ\x01] You are now showing other players.");
	}
	else {
		gB_ShowingPlayers[client] = false;
		PrintToChat(client, "[\x06KZ\x01] You are now hiding other players.");
	}
	return Plugin_Handled;
}

public Action CommandGoto(int client, int args) {
	// If no arguments, respond with error message
	if (args < 1) {
		PrintToChat(client, "[\x06KZ\x01] Please specify a player to go to.");
	}
	// Otherwise try to teleport to the player
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, false, false);
		if (target != -1) {
			if (target == client) {
				PrintToChat(client, "[\x06KZ\x01] You can't teleport to yourself.");
			}
			else if (!IsPlayerAlive(target)) {
				PrintToChat(client, "[\x06KZ\x01] The player you specified is not alive.");
			}
			else {
				TeleportToOtherPlayer(client, target);
				if (gB_TimerRunning[client]) {
					PrintToChat(client, "[\x06KZ\x01] Your time has been stopped because you used !goto.");
				}
				ForceStopTimer(client);
			}
		}
	}
	return Plugin_Handled;
}

public Action CommandSpec(int client, int args) {
	// If no arguments, just join spectators
	if (args < 1) {
		JoinTeam(client, CS_TEAM_SPECTATOR);
	}
	// Otherwise try to spectate the player
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, false, false);
		if (target != -1) {
			if (target == client) {
				PrintToChat(client, "[\x06KZ\x01] You can't spectate yourself.");
			}
			else if (!IsPlayerAlive(target)) {
				PrintToChat(client, "[\x06KZ\x01] The player you specified is not alive.");
			}
			else {
				JoinTeam(client, CS_TEAM_SPECTATOR);
				SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
				SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", target);
			}
		}
	}
	return Plugin_Handled;
}

public Action CommandToggleInfoPanel(int client, int args) {
	if (gB_ShowingInfoPanel[client]) {
		gB_ShowingInfoPanel[client] = false;
		PrintToChat(client, "[\x06KZ\x01] Your centre info panel has been disabled.");
	}
	else {
		gB_ShowingInfoPanel[client] = true;
		PrintToChat(client, "[\x06KZ\x01] Your centre info panel has been enabled.");
	}
	return Plugin_Handled;
}

public Action CommandToggleHideWeapon(int client, int args) {
	if (!gB_ShowingWeapon[client]) {
		gB_ShowingWeapon[client] = true;
		PrintToChat(client, "[\x06KZ\x01] You are now showing your weapon.");
	}
	else {
		gB_ShowingWeapon[client] = false;
		PrintToChat(client, "[\x06KZ\x01] You are now hiding your weapon.");
	}
	SetDrawViewModel(client, gB_ShowingWeapon[client]);
	return Plugin_Handled;
}

public Action CommandToggleShowKeys(int client, int args) {
	if (gB_ShowingKeys[client]) {
		gB_ShowingKeys[client] = false;
		PrintToChat(client, "[\x06KZ\x01] You are no longer showing your key presses to yourself.");
	}
	else {
		gB_ShowingKeys[client] = true;
		PrintToChat(client, "[\x06KZ\x01] You are now showing your key presses to yourself.");
	}
	return Plugin_Handled;
}

public Action CommandMeasureMenu(int client, int args) {
	DisplayMenu(gH_MeasureMenu, client, MENU_TIME_FOREVER);
}

public Action CommandPistolMenu(int client, int args) {
	DisplayMenu(gH_PistolMenu, client, MENU_TIME_FOREVER);
}

public Action CommandToggleNoclip(int client, int args) {
	if (g_MovementPlayer[client].moveType != MOVETYPE_NOCLIP) {
		g_MovementPlayer[client].moveType = MOVETYPE_NOCLIP;
	}
	else {
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	}
	return Plugin_Handled;
}

public Action CommandEnableNoclip(int client, int args) {
	g_MovementPlayer[client].moveType = MOVETYPE_NOCLIP;
	return Plugin_Handled;
}

public Action CommandDisableNoclip(int client, int args) {
	g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	return Plugin_Handled;
}



/*===============================  Database Command Handlers  ===============================*/

public Action CommandMapRank(int client, int args) {
	if (args < 1) {
		DB_PrintPBs(client, client, gC_CurrentMap);
	}
	else if (args == 1) {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, true, false);
		if (target != -1) {
			DB_PrintPBs(client, target, gC_CurrentMap);
		}
	}
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		char specifiedMap[33];
		GetCmdArg(2, specifiedMap, sizeof(specifiedMap));
		
		int target = FindTarget(client, specifiedPlayer, true, false);
		if (target != -1) {
			DB_PrintPBs(client, target, specifiedMap);
		}
	}
	return Plugin_Handled;
}

public Action CommandMapRecord(int client, int args) {
	if (args < 1) {
		DB_PrintMapRecords(client, gC_CurrentMap);
	}
	else {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_PrintMapRecords(client, specifiedMap);
	}
	return Plugin_Handled;
}

public Action CommandMapTop(int client, int args) {
	if (args < 1) {
		gC_MapTopMap[client] = gC_CurrentMap;
	}
	else {
		GetCmdArg(1, gC_MapTopMap[client], sizeof(gC_MapTopMap[]));
	}
	OpenMapTopMenu(client);
	return Plugin_Handled;
} 