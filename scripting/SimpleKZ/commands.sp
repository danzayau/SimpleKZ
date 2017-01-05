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
	RegConsoleCmd("sm_stopsound", CommandStopsound, "[KZ] Stops all sounds e.g. map soundscapes (music).");
	RegConsoleCmd("sm_hide", CommandHide, "[KZ] Hides other players.");
	RegConsoleCmd("sm_goto", CommandGoto, "[KZ] Teleport to another player.");
	RegConsoleCmd("sm_spec", CommandSpec, "[KZ] Spectate another player.");
	RegConsoleCmd("sm_speed", CommandToggleInfoPanel, "[KZ] Toggle visibility of the centre information panel.");
	RegConsoleCmd("sm_hideweapon", CommandToggleHideWeapon, "[KZ] Toggle visibility of your weapon.");
	RegConsoleCmd("sm_pistol", CommandPistolMenu, "[KZ] Open the pistol selection menu.");
	RegConsoleCmd("sm_showkeys", CommandToggleShowKeys, "[KZ] Toggles showing your key presses to yourself.");
	RegConsoleCmd("+noclip", CommandEnableNoclip, "[KZ] Noclip on.");
	RegConsoleCmd("-noclip", CommandDisableNoclip, "[KZ] Noclip off.");
}



/*======  Command Handlers  ======*/

public Action CommandToggleMenu(int client, int args) {
	if (gB_UsingTeleportMenu[client]) {
		gB_UsingTeleportMenu[client] = false;
		CloseTeleportMenu(client);
		PrintToChat(client, "[\x06KZ\x01] Your teleport menu has been disabled.");
	}
	else {
		gB_UsingTeleportMenu[client] = true;
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

public Action CommandStopsound(int client, int args) {
	ClientCommand(client, "snd_playsounds Music.StopAllExceptMusic");
	PrintToChat(client, "[\x06KZ\x01] You have stopped all sounds.");
	return Plugin_Handled;
}

public Action CommandHide(int client, int args) {
	if (gB_HidingPlayers[client]) {
		gB_HidingPlayers[client] = false;
		PrintToChat(client, "[\x06KZ\x01] You are now showing other players.");
	}
	else {
		gB_HidingPlayers[client] = true;
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
	if (gB_UsingInfoPanel[client]) {
		gB_UsingInfoPanel[client] = false;
		PrintToChat(client, "[\x06KZ\x01] Your centre info panel has been disabled.");
	}
	else {
		gB_UsingInfoPanel[client] = true;
		PrintToChat(client, "[\x06KZ\x01] Your centre info panel has been enabled.");
	}
	return Plugin_Handled;
}

public Action CommandToggleHideWeapon(int client, int args) {
	if (gB_HidingWeapon[client]) {
		gB_HidingWeapon[client] = false;
		PrintToChat(client, "[\x06KZ\x01] You are now showing your weapon.");
	}
	else {
		gB_HidingWeapon[client] = true;
		PrintToChat(client, "[\x06KZ\x01] You are now hiding your weapon.");
	}
	SetDrawViewModel(client, !gB_HidingWeapon[client]);
	return Plugin_Handled;
}

public Action CommandPistolMenu(int client, int args) {
	DisplayMenu(gH_PistolMenu, client, MENU_TIME_FOREVER);
}

public Action CommandEnableNoclip(int client, int args) {
	if (gB_TimerRunning[client]) {
		PrintToChat(client, "[\x06KZ\x01] Your time has been stopped because you used +noclip.");
	}
	ForceStopTimer(client);
	g_MovementPlayer[client].moveType = MOVETYPE_NOCLIP;
	return Plugin_Handled;
}

public Action CommandDisableNoclip(int client, int args) {
	g_MovementPlayer[client].moveType = MOVETYPE_WALK;
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