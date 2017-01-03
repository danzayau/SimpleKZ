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

void LoadKZConfig() {
	char kzConfigPath[] = "sourcemod/simplekz/kz.cfg";
	char kzConfigPathFull[64];
	Format(kzConfigPathFull, sizeof(kzConfigPathFull), "cfg/%s", kzConfigPath);
	
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
	
	GetClientAbsOrigin(target, targetOrigin);
	GetClientEyeAngles(target, targetAngles);
	GetClientName(target, targetName, MAX_NAME_LENGTH);
	
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		ChangeClientTeam(client, CS_TEAM_CT);
	}
	// Respawn the player if necessary
	if (!IsPlayerAlive(client)) {
		CS_RespawnPlayer(client);
	}
	TeleportEntity(client, targetOrigin, targetAngles, view_as<float>( { 0.0, 0.0, -100.0 } ));
	PrintToChat(client, "[KZ] You have teleported to %s.", targetName);
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



/*=====  String Formatters  ======*/

char[] GetRunTypeString(int client) {
	char runTypeString[64];
	if (GetRunType(client) == 0) {
		Format(runTypeString, sizeof(runTypeString), "PRO");
	}
	else {
		Format(runTypeString, sizeof(runTypeString), "TP");
	}
	return runTypeString;
}

char[] GetEndTimeString(int client) {
	char endTimeString[256], clientName[64];
	GetClientName(client, clientName, sizeof(clientName));
	
	if (GetRunType(client) == 0) {
		Format(endTimeString, sizeof(endTimeString), "[KZ] %s finished in %s (%s).", 
			clientName, TimerFormatTime(gF_CurrentTime[client]), GetRunTypeString(client));
	}
	else {
		Format(endTimeString, sizeof(endTimeString), "[KZ] %s finished in %s (TPs: %d, Waste: %s).", 
			clientName, TimerFormatTime(gF_CurrentTime[client]), gI_TeleportsUsed[client], TimerFormatTime(gF_WastedTime[client]));
	}
	return endTimeString;
}

char[] TimerFormatTime(float timeToFormat) {
	char formattedTime[64];
	
	int roundedTime = RoundFloat(timeToFormat * 100); // Time rounded to number of centiseconds
	
	int centiseconds = roundedTime % 100;
	roundedTime = (roundedTime - centiseconds) / 100;
	int seconds = roundedTime % 60;
	roundedTime = (roundedTime - seconds) / 60;
	int minutes = roundedTime % 60;
	roundedTime = (roundedTime - minutes) / 60;
	int hours = roundedTime;
	
	if (hours == 0) {
		Format(formattedTime, sizeof(formattedTime), "%02d:%02d.%02d", minutes, seconds, centiseconds);
	}
	else {
		Format(formattedTime, sizeof(formattedTime), "%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds);
	}
	return formattedTime;
}



/*=====  Pistol Menu ======*/

// Pistol Entity Names
char gC_Pistols[NUMBER_OF_PISTOLS][3][] = 
{
	{ "weapon_hkp2000", "P2K / USP", "CT" }, 
	{ "weapon_glock", "Glock", "T" }, 
	{ "weapon_p250", "P250", "EITHER" }, 
	{ "weapon_deagle", "Deagle", "EITHER" }, 
	{ "weapon_elite", "Dualies", "EITHER" }, 
	{ "weapon_cz75a", "CZ75", "EITHER" }, 
	{ "weapon_fiveseven", "Five-SeveN", "CT" }, 
	{ "weapon_tec9", "Tec-9", "T" }, 
	{ "weapon_revolver", "R8 Revolver", "EITHER" }
};

void SetupPistolMenu() {
	gH_PistolMenu = CreateMenu(MenuHandler_Pistol);
	SetMenuTitle(gH_PistolMenu, "Pistols");
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
	if (playerTeam > 0) {
		CS_SwitchTeam(client, playerTeam);
	}
} 