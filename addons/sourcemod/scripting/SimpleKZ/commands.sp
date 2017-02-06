/*	commands.sp
	
	Commands for player use.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_menu", CommandToggleMenu, "[KZ] Toggle the visibility of the teleport menu.");
	RegConsoleCmd("sm_checkpoint", CommandMakeCheckpoint, "[KZ] Set your checkpoint.");
	RegConsoleCmd("sm_gocheck", CommandTeleportToCheckpoint, "[KZ] Teleport to your checkpoint.");
	RegConsoleCmd("sm_undo", CommandUndoTeleport, "[KZ] Undo teleport.");
	RegConsoleCmd("sm_start", CommandTeleportToStart, "[KZ] Teleport to the start of the map.");
	RegConsoleCmd("sm_r", CommandTeleportToStart, "[KZ] Teleport to the start of the map.");
	RegConsoleCmd("sm_pause", CommandTogglePause, "[KZ] Toggle pausing your timer and stopping you in your position.");
	RegConsoleCmd("sm_resume", CommandTogglePause, "[KZ] Toggle pausing your timer and stopping you in your position.");
	RegConsoleCmd("sm_stop", CommandStopTimer, "[KZ] Stop your timer.");
	RegConsoleCmd("sm_stopsound", CommandStopsound, "[KZ] Stop all sounds e.g. map soundscapes (music).");
	RegConsoleCmd("sm_goto", CommandGoto, "[KZ] Teleport to another player. Usage: !goto <player>");
	RegConsoleCmd("sm_spec", CommandSpec, "[KZ] Spectate another player. Usage: !spec <player>");
	RegConsoleCmd("sm_options", CommandOptions, "[KZ] Open up the options menu.");
	RegConsoleCmd("sm_hide", CommandToggleShowPlayers, "[KZ] Toggle hiding other players.");
	RegConsoleCmd("sm_speed", CommandToggleInfoPanel, "[KZ] Toggle visibility of the centre information panel.");
	RegConsoleCmd("sm_hideweapon", CommandToggleShowWeapon, "[KZ] Toggle visibility of your weapon.");
	RegConsoleCmd("sm_measure", CommandMeasureMenu, "[KZ] Open the measurement menu.");
	RegConsoleCmd("sm_pistol", CommandPistolMenu, "[KZ] Open the pistol selection menu.");
	RegConsoleCmd("sm_nc", CommandToggleNoclip, "[KZ] Toggle noclip.");
	RegConsoleCmd("+noclip", CommandEnableNoclip, "[KZ] Noclip on.");
	RegConsoleCmd("-noclip", CommandDisableNoclip, "[KZ] Noclip off.");
	RegConsoleCmd("sm_split", CommandSplit, "[KZ] Make a time split for timing purposes.");
}



/*===============================  Command Listener Handlers  ===============================*/

public Action CommandBlock(int client, const char[] command, int argc) {
	return Plugin_Handled;
}

// Allow unlimited team changes
public Action CommandJoinTeam(int client, const char[] command, int argc) {
	char teamString[4];
	GetCmdArgString(teamString, sizeof(teamString));
	int team = StringToInt(teamString);
	JoinTeam(client, team);
	return Plugin_Handled;
}



/*===============================  Command Handlers  ===============================*/

public Action CommandToggleMenu(int client, int args) {
	ToggleTeleportMenu(client);
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
	SimpleKZ_ForceStopTimer(client);
	CPrintToChat(client, "%t %t", "KZ_Tag", "TimeStopped_Generic");
	return Plugin_Handled;
}

public Action CommandStopsound(int client, int args) {
	ClientCommand(client, "snd_playsounds Music.StopAllExceptMusic");
	CPrintToChat(client, "%t %t", "KZ_Tag", "StopSound");
	return Plugin_Handled;
}

public Action CommandGoto(int client, int args) {
	// If no arguments, respond with error message
	if (args < 1) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Goto_NoPlayer");
	}
	// Otherwise try to teleport to the player
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, false, false);
		if (target != -1) {
			if (target == client) {
				CPrintToChat(client, "%t %t", "KZ_Tag", "Goto_NotYourself");
			}
			else if (!IsPlayerAlive(target)) {
				CPrintToChat(client, "%t %t", "KZ_Tag", "Goto_NotAlive");
			}
			else {
				TeleportToOtherPlayer(client, target);
				if (gB_TimerRunning[client]) {
					CPrintToChat(client, "%t %t", "KZ_Tag", "TimeStopped_Goto");
				}
				SimpleKZ_ForceStopTimer(client);
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
				CPrintToChat(client, "%t %t", "KZ_Tag", "Spec_NotYourself");
			}
			else if (!IsPlayerAlive(target)) {
				CPrintToChat(client, "%t %t", "KZ_Tag", "Spec_NotAlive");
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

public Action CommandOptions(int client, int args) {
	DisplayOptionsMenu(client);
	return Plugin_Handled;
}

public Action CommandToggleShowPlayers(int client, int args) {
	ToggleShowPlayers(client);
	return Plugin_Handled;
}

public Action CommandToggleInfoPanel(int client, int args) {
	ToggleInfoPanel(client);
	return Plugin_Handled;
}

public Action CommandToggleShowWeapon(int client, int args) {
	ToggleShowWeapon(client);
	return Plugin_Handled;
}

public Action CommandMeasureMenu(int client, int args) {
	DisplayMeasureMenu(client);
	return Plugin_Handled;
}

public Action CommandPistolMenu(int client, int args) {
	DisplayPistolMenu(client);
	return Plugin_Handled;
}

public Action CommandToggleNoclip(int client, int args) {
	ToggleNoclip(client);
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

public Action CommandSplit(int client, int args) {
	SplitMake(client);
	return Plugin_Handled;
} 