/*	misc.sp

	Miscellaneous, non-specific functions.
*/


bool IsValidClient(int client) {
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

float FloatMax(float a, float b) {
	if (a > b) {
		return a;
	}
	return b;
}

bool IntToBool(int value) {
	if (value == 0) {
		return false;
	}
	return true;
}

int BoolToInt(bool boolean) {
	if (boolean) {
		return 1;
	}
	return 0;
}

void SetupMovementMethodmaps() {
	for (int client = 1; client <= MaxClients; client++) {
		g_MovementPlayer[client] = new MovementPlayer(client);
	}
}

void LoadKZConfig() {
	char kzConfigPath[] = "sourcemod/simplekz/kz.cfg";
	char kzConfigPathFull[64];
	FormatEx(kzConfigPathFull, sizeof(kzConfigPathFull), "cfg/%s", kzConfigPath);
	
	if (FileExists(kzConfigPathFull)) {
		ServerCommand("exec %s", kzConfigPath);
	}
	else {
		SetFailState("Failed to load config (cfg/%s not found).", kzConfigPath);
	}
}

void AddCommandListeners() {
	AddCommandListener(CommandJoinTeam, "jointeam");
}

int GetSpectatedPlayer(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

void SetDrawViewModel(int client, bool drawViewModel) {
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", drawViewModel);
}

public Action CleanHUD(Handle timer, int client) {
	// Hide radar
	int clientEntFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
	SetEntProp(client, Prop_Send, "m_iHideHUD", clientEntFlags | (1 << 12));
}

void TeleportToOtherPlayer(int client, int target)
{
	float targetOrigin[3];
	float targetAngles[3];
	char targetName[MAX_NAME_LENGTH];
	
	g_MovementPlayer[target].GetOrigin(targetOrigin);
	g_MovementPlayer[target].GetEyeAngles(targetOrigin);
	GetClientName(target, targetName, MAX_NAME_LENGTH);
	
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	// Respawn the player if necessary
	if (!IsPlayerAlive(client)) {
		CS_RespawnPlayer(client);
	}
	TeleportEntity(client, targetOrigin, targetAngles, view_as<float>( { 0.0, 0.0, -100.0 } ));
	PrintToChat(client, "[\x06KZ\x01] You have teleported to %s.", targetName);
}

int GetRunType(int client) {
	// Returns 0 for PRO run
	if (gI_TeleportsUsed[client] == 0) {
		return 0;
	}
	// Returns 1 for TP run
	else {
		return 1;
	}
}

void FreezePlayer(int client) {
	g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	g_MovementPlayer[client].moveType = MOVETYPE_NONE;
}

void JoinTeam(int client, int team) {
	if (team == CS_TEAM_SPECTATOR) {
		g_MovementPlayer[client].GetOrigin(gF_SavedOrigin[client]);
		g_MovementPlayer[client].GetEyeAngles(gF_SavedAngles[client]);
		gB_HasSavedPosition[client] = true;
		if (gB_TimerRunning[client]) {
			gB_Paused[client] = true;
		}
		ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	}
	else if (team == CS_TEAM_CT || team == CS_TEAM_T) {
		// Switch teams without killing them (no death notice)
		CS_SwitchTeam(client, team);
		CS_RespawnPlayer(client);
		if (gB_HasSavedPosition[client]) {
			TeleportEntity(client, gF_SavedOrigin[client], gF_SavedAngles[client], view_as<float>( { 0.0, 0.0, -50.0 } ));
			if (gB_Paused[client]) {
				FreezePlayer(client);
			}
		}
	}
	CloseTeleportMenu(client);
}



/*=====  String Formatters  ======*/

char[] GetRunTypeString(int client) {
	char runTypeString[4];
	if (GetRunType(client) == 0) {
		FormatEx(runTypeString, sizeof(runTypeString), "PRO");
	}
	else {
		FormatEx(runTypeString, sizeof(runTypeString), "TP");
	}
	return runTypeString;
}

char[] GetEndTimeString(int client) {
	char endTimeString[256], clientName[64];
	GetClientName(client, clientName, sizeof(clientName));
	
	if (GetRunType(client) == 0) {
		FormatEx(endTimeString, sizeof(endTimeString), 
			"[\x06KZ\x01] \x05%s\x01 finished in \x0A%s\x01 (\x0APRO\x01).", 
			clientName, 
			TimerFormatTime(gF_CurrentTime[client]), 
			GetRunTypeString(client));
	}
	else {
		FormatEx(endTimeString, sizeof(endTimeString), 
			"[\x06KZ\x01] \x05%s\x01 finished in \x09%s\x01 (\x09%d\x01 TP | \x08%s\x01).", 
			clientName, 
			TimerFormatTime(gF_CurrentTime[client]), 
			gI_TeleportsUsed[client], 
			TimerFormatTime(gF_CurrentTime[client] - gF_WastedTime[client]));
	}
	return endTimeString;
}

char[] TimerFormatTime(float timeToFormat) {
	char formattedTime[16];
	
	int roundedTime = RoundFloat(timeToFormat * 100); // Time rounded to number of centiseconds
	
	int centiseconds = roundedTime % 100;
	roundedTime = (roundedTime - centiseconds) / 100;
	int seconds = roundedTime % 60;
	roundedTime = (roundedTime - seconds) / 60;
	int minutes = roundedTime % 60;
	roundedTime = (roundedTime - minutes) / 60;
	int hours = roundedTime;
	
	if (hours == 0) {
		FormatEx(formattedTime, sizeof(formattedTime), "%02d:%02d.%02d", minutes, seconds, centiseconds);
	}
	else {
		FormatEx(formattedTime, sizeof(formattedTime), "%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds);
	}
	return formattedTime;
}



/*=====  Pistol Menu ======*/

// Pistol Entity Names (entity class name, alias, team that buys it)
char gC_Pistols[NUMBER_OF_PISTOLS][3][] = 
{
	{ "weapon_hkp2000", "P2K / USP", "CT" }, 
	{ "weapon_glock", "Glock", "T" }, 
	{ "weapon_p250", "P250", "EITHER" }, 
	{ "weapon_deagle", "Deagle", "EITHER" }, 
	{ "weapon_elite", "Dualies", "EITHER" }, 
	{ "weapon_cz75a", "CZ75", "EITHER" }, 
	{ "weapon_fiveseven", "Five-SeveN", "CT" }, 
	{ "weapon_tec9", "Tec-9", "T" }
};

void SetupPistolMenu() {
	gH_PistolMenu = CreateMenu(MenuHandler_Pistol);
	SetMenuTitle(gH_PistolMenu, "Pick a Pistol");
	for (int pistol = 0; pistol < NUMBER_OF_PISTOLS; pistol++) {
		AddMenuItem(gH_PistolMenu, gC_Pistols[pistol][1], gC_Pistols[pistol][1]);
	}
}

public int MenuHandler_Pistol(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		gI_Pistol[param1] = param2;
		GivePlayerPistol(param1, param2);
	}
}

void GivePlayerPistol(int client, int pistol) {
	int playerTeam = GetClientTeam(client);
	// Switch teams to the side that buys that gun so that gun skins load
	if (strcmp(gC_Pistols[pistol][2], "CT") == 0 && playerTeam != CS_TEAM_CT) {
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	else if (strcmp(gC_Pistols[pistol][2], "T") == 0 && playerTeam != CS_TEAM_T) {
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	// Give the player this pistol
	int currentPistol = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (currentPistol != -1) {
		RemovePlayerItem(client, currentPistol);
	}
	GivePlayerItem(client, gC_Pistols[pistol][0]);
	// Go back to original team
	if (1 <= playerTeam && playerTeam <= 3) {
		CS_SwitchTeam(client, playerTeam);
	}
} 