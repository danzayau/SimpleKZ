/*	misc.sp

	Miscellaneous functions.
*/


/*===============================  General  ===============================*/

bool IsValidClient(int client) {
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

void SetupMovementMethodmaps() {
	for (int client = 1; client <= MaxClients; client++) {
		g_MovementPlayer[client] = new MovementPlayer(client);
	}
}

float FloatMax(float a, float b) {
	if (a > b) {
		return a;
	}
	return b;
}

int BoolToInt(bool boolean) {
	if (boolean) {
		return 1;
	}
	return 0;
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

void OnMapStartVariableUpdates() {
	UpdateCurrentMap();
	gI_GlowSprite = PrecacheModel("materials/sprites/bluelaser1.vmt", true); // Measure
}

void UpdateCurrentMap() {
	// Store map name
	GetCurrentMap(gC_CurrentMap, sizeof(gC_CurrentMap));
	// Get just the map name (e.g. remove workshop/id/ prefix)
	char mapPieces[5][64];
	int lastPiece = ExplodeString(gC_CurrentMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(gC_CurrentMap, sizeof(gC_CurrentMap), "%s", mapPieces[lastPiece - 1]);
	
	// Check for kzpro_ tag
	char mapPrefix[1][64];
	ExplodeString(gC_CurrentMap, "_", mapPrefix, sizeof(mapPrefix), sizeof(mapPrefix[]));
	gB_CurrentMapIsKZPro = StrEqual(mapPrefix[0], "kzpro", false);
}

void FakePrecacheSound(const char[] szPath) {
	AddToStringTable(FindStringTable("soundprecache"), szPath);
}

char[] FormatTimeFloat(float timeToFormat) {
	char formattedTime[12];
	
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

void GetClientCountry(int client) {
	char clientIP[32];
	GetClientIP(client, clientIP, sizeof(clientIP));
	if (!GeoipCountry(clientIP, gC_Country[client], sizeof(gC_Country[]))) {
		gC_Country[client] = "Unknown";
	}
}

void GetClientSteamID(int client) {
	GetClientAuthId(client, AuthId_Steam2, gC_SteamID[client], 24, true);
}

void GetClientSteamIDAll() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientAuthorized(client)) {
			GetClientSteamID(client);
		}
	}
}

void PrintNoDBMessage(int client) {
	PrintToChat(client, "[\x06KZ\x01] This server isn't connected to a \x06SimpleKZ\x01 database.");
}



/*===============================  Client  ===============================*/

public Action CleanHUD(Handle timer, int client) {
	// Hide radar
	int clientEntFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
	SetEntProp(client, Prop_Send, "m_iHideHUD", clientEntFlags | (1 << 12));
}

void SetDefaultPreferences(int client) {
	gB_ShowingTeleportMenu[client] = true;
	gB_ShowingInfoPanel[client] = true;
	gB_ShowingKeys[client] = false;
	gB_ShowingPlayers[client] = true;
	gB_ShowingWeapon[client] = true;
	gI_Pistol[client] = 0;
}

void SetDrawViewModel(int client, bool drawViewModel) {
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", drawViewModel);
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

int GetSpectatedPlayer(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
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

void FreezePlayer(int client) {
	g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	g_MovementPlayer[client].moveType = MOVETYPE_NONE;
} 