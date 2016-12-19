/*	conmands.sp
	
	Implements commands for player control over features of the plugin.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_menu", CommandToggleMenu, "[KZ] Toggles the visibility of the timer menu.");
	RegConsoleCmd("sm_checkpoint", CommandMakeCheckpoint, "[KZ] Set a checkpoint.");
	RegConsoleCmd("sm_gocheck", CommandTeleportToCheckpoint, "[KZ] Teleport to the checkpoint.");
	RegConsoleCmd("sm_undo", CommandUndoTeleport, "[KZ] Undo teleport to checkpoint.");
	RegConsoleCmd("sm_start", CommandTeleportToStart, "[KZ] Teleports you to the start of the map.");
	RegConsoleCmd("sm_r", CommandTeleportToStart, "[KZ] Teleports you to the start of the map.");
	RegConsoleCmd("sm_stopsound", CommandStopsound, "[KZ] Stops all sounds e.g. map soundscapes (music).");
	RegConsoleCmd("sm_hide", CommandHide, "[KZ] Hides other players.");
	RegConsoleCmd("sm_goto", CommandGoto, "[KZ] Teleport to another player.");
	RegConsoleCmd("sm_spec", CommandSpec, "[KZ] Spectate another player.");
	RegConsoleCmd("sm_watch", CommandSpec, "[KZ] Spectate another player.");
	RegConsoleCmd("+noclip", CommandEnableNoclip, "[KZ] Noclip on.");
	RegConsoleCmd("-noclip", CommandDisableNoclip, "[KZ] Noclip off.");
}


// Command Handlers

public Action CommandToggleMenu(client, args) {
	if (g_clientUsingTeleportMenu[client]) {
		g_clientUsingTeleportMenu[client] = false;
		PrintToChat(client, "[KZ] Your teleport menu has been disabled.");
	}
	else {
		g_clientUsingTeleportMenu[client] = true;
		PrintToChat(client, "[KZ] Your teleport menu has been enabled.");
	}
	return Plugin_Handled;
}

public Action CommandMakeCheckpoint(client, args) {
	MakeCheckpoint(client);
	return Plugin_Handled;
}

public Action CommandTeleportToCheckpoint(client, args) {
	TeleportToCheckpoint(client);
	return Plugin_Handled;
}

public Action CommandUndoTeleport(client, args) {
	UndoTeleport(client);
	return Plugin_Handled;
}

public Action CommandTeleportToStart(client, args) {
	TeleportToStart(client);
	return Plugin_Handled;
}

public Action CommandStopsound(client, args) {
	ClientCommand(client, "snd_playsounds Music.StopAllExceptMusic");
	PrintToChat(client, "[KZ] You have stopped all sounds.");
	return Plugin_Handled;
}

public Action CommandHide(client, args) {
	if (g_clientHidingPlayers[client]) {
		g_clientHidingPlayers[client] = false;
		PrintToChat(client, "[KZ] You are now showing other players.");
	}
	else {
		g_clientHidingPlayers[client] = true;
		PrintToChat(client, "[KZ] You are now hiding other players.");
	}
	return Plugin_Handled;
}

public Action CommandGoto(client, args) {
	if (!IsPlayerAlive(client)) {
		ReplyToCommand(client, "[KZ] You must be alive to use this command.");
	}
	
	else if (args < 1) {  // No arguments
		ReplyToCommand(client, "[KZ] Please specify a player to goto.");
	}
	
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, false, false);
		
		if (target != -1) {
			if (target != client) {
				TeleportToOtherPlayer(client, target);
				g_clientTimerRunning[client] = false;
			}
			else {
				ReplyToCommand(client, "[KZ] You can't goto yourself.");
			}
		}
	}
	return Plugin_Handled;
}

public Action CommandSpec(client, args) {
	if (args < 1) {
		ChangeClientTeam(client, 1);
		g_clientTimerRunning[client] = false;
	}
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, false, false);
		
		if (target != -1) {
			if (target != client) {
				if (IsPlayerAlive(target)) {
					ChangeClientTeam(client, 1);
					SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
					SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", target);
					g_clientTimerRunning[client] = false;
				}
				else {
					ReplyToCommand(client, "[KZ] The player you specified is not alive.");
				}
			}
			else {
				ReplyToCommand(client, "[KZ] You can't spectate yourself.");
			}
		}		
	}
	return Plugin_Handled;
}

public Action CommandEnableNoclip(client, args) {
	if (g_clientTimerRunning[client])
	{
		g_clientTimerRunning[client] = false;
		PrintToChat(client, "[KZ] Your time has been stopped because you used noclip.");
	}
	SetEntityMoveType(client, MOVETYPE_NOCLIP);
	return Plugin_Handled;
}

public Action CommandDisableNoclip(client, args) {
	SetEntityMoveType(client, MOVETYPE_WALK);
	return Plugin_Handled;
} 