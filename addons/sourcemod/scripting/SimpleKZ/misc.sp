/*	misc.sp

	Miscellaneous functions.
*/


/*===============================  General  ===============================*/

float FloatMax(float a, float b) {
	if (a > b) {
		return a;
	}
	return b;
}

void SetupMovementMethodmaps() {
	for (int client = 1; client <= MaxClients; client++) {
		g_MovementPlayer[client] = new MovementPlayer(client);
	}
}

void AddCommandListeners() {
	AddCommandListener(CommandJoinTeam, "jointeam");
	// Block radio commands
	for (int i = 0; i < sizeof(gC_RadioCommands); i++) {
		AddCommandListener(CommandBlock, gC_RadioCommands[i]);
	}
}

bool IsValidClient(int client) {
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

void LoadKZConfig() {
	char kzConfigPath[] = "sourcemod/SimpleKZ/kz.cfg";
	char kzConfigPathFull[64];
	FormatEx(kzConfigPathFull, sizeof(kzConfigPathFull), "cfg/%s", kzConfigPath);
	
	if (FileExists(kzConfigPathFull)) {
		ServerCommand("exec %s", kzConfigPath);
	}
	else {
		SetFailState("Failed to load config (cfg/%s not found).", kzConfigPath);
	}
}

void OnMapStartVariableUpdates() {
	UpdateCurrentMap();
	gI_GlowSprite = PrecacheModel("materials/sprites/bluelaser1.vmt", true); // Measure
}

void UpdateCurrentMap() {
	char map[64];
	GetCurrentMap(map, sizeof(map));
	// Get just the map name (e.g. remove workshop/id/ prefix)
	char mapPieces[5][64];
	int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(map, sizeof(map), "%s", mapPieces[lastPiece - 1]);
	// Check for kzpro_ tag
	char mapPrefix[1][64];
	ExplodeString(map, "_", mapPrefix, sizeof(mapPrefix), sizeof(mapPrefix[]));
	gB_CurrentMapIsKZPro = StrEqual(mapPrefix[0], "kzpro", false);
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



/*===============================  Client  ===============================*/

void SetupClient(int client) {
	GetClientCountry(client);
	GetClientSteamID(client);
	DB_SavePlayerInfo(client);
	DB_LoadPreferences(client);
	
	UpdatePistolMenu(client);
	UpdateMeasureMenu(client);
	UpdateOptionsMenu(client);
	TimerSetup(client);
	MeasureResetPos(client);
	SplitsSetup(client);
	NoBhopBlockCPSetup(client);
}

public Action CleanHUD(Handle timer, int client) {
	if (IsValidClient(client)) {
		// Hide radar
		int clientEntFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
		SetEntProp(client, Prop_Send, "m_iHideHUD", clientEntFlags | (1 << 12));
	}
	return Plugin_Continue;
}

public Action SlayPlayer(Handle timer, int client) {
	if (IsValidClient(client)) {
		ForcePlayerSuicide(client);
	}
	return Plugin_Continue;
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
			Pause(client);
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
			gB_HasSavedPosition[client] = false;
		}
		else {
			// The player will be teleported to the spawn point, so force stop their timer
			SimpleKZ_ForceStopTimer(client);
		}
	}
	CloseTeleportMenu(client);
}

void TeleportToOtherPlayer(int client, int target)
{
	float targetOrigin[3];
	float targetAngles[3];
	
	g_MovementPlayer[target].GetOrigin(targetOrigin);
	g_MovementPlayer[target].GetEyeAngles(targetAngles);
	
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	// Respawn the player if necessary
	if (!IsPlayerAlive(client)) {
		CS_RespawnPlayer(client);
	}
	TeleportEntity(client, targetOrigin, targetAngles, view_as<float>( { 0.0, 0.0, -100.0 } ));
	CPrintToChat(client, "%t %t", "KZ_Tag", "Goto_Success", target);
}

int GetSpectatedPlayer(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

void EmitSoundToClientSpectators(int client, const char[] sound) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && GetSpectatedPlayer(i) == client) {
			EmitSoundToClient(i, sound);
		}
	}
}

void FreezePlayer(int client) {
	g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	g_MovementPlayer[client].moveType = MOVETYPE_NONE;
}

void ToggleNoclip(int client) {
	if (g_MovementPlayer[client].moveType != MOVETYPE_NOCLIP) {
		g_MovementPlayer[client].moveType = MOVETYPE_NOCLIP;
	}
	else {
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	}
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

void PrintConnectMessage(int client) {
	char clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, MAX_NAME_LENGTH);
	CPrintToChatAll("%T", "Client_Connect", client, clientName, gC_Country[client]);
}

void PrintDisconnectMessage(int client, const char[] reason) {
	char clientName[MAX_NAME_LENGTH];
	GetClientName(client, clientName, MAX_NAME_LENGTH);
	CPrintToChatAll("%T", "Client_Disconnect", client, clientName, reason);
}

RunType GetCurrentRunType(int client) {
	if (gI_TeleportsUsed[client] == 0) {
		return PRO;
	}
	else {
		return TP;
	}
}

public Action ZeroVelocity(Handle timer, int client) {
	if (IsValidClient(client)) {
		g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, -0.0 } ));
		g_MovementPlayer[client].SetBaseVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	}
	return Plugin_Continue;
}



/*===============================  Options  ===============================*/

void SetDefaultPreferences(int client) {
	gB_ShowingTeleportMenu[client] = true;
	gB_ShowingInfoPanel[client] = true;
	gB_ShowingKeys[client] = false;
	gB_ShowingPlayers[client] = true;
	gB_ShowingWeapon[client] = true;
	gB_AutoRestart[client] = false;
	gB_SlayOnEnd[client] = false;
	gI_Pistol[client] = 0;
}

void ToggleTeleportMenu(int client) {
	if (gB_ShowingTeleportMenu[client]) {
		gB_ShowingTeleportMenu[client] = false;
		CloseTeleportMenu(client);
		CPrintToChat(client, "%t %t", "KZ_Tag", "TeleportMenu_Disable");
	}
	else {
		gB_ShowingTeleportMenu[client] = true;
		CPrintToChat(client, "%t %t", "KZ_Tag", "TeleportMenu_Enable");
	}
}

void ToggleShowPlayers(int client) {
	if (gB_ShowingPlayers[client]) {
		gB_ShowingPlayers[client] = false;
		CPrintToChat(client, "%t %t", "KZ_Tag", "ShowPlayers_Disable");
	}
	else {
		gB_ShowingPlayers[client] = true;
		CPrintToChat(client, "%t %t", "KZ_Tag", "ShowPlayers_Enable");
	}
}

void ToggleInfoPanel(int client) {
	if (gB_ShowingInfoPanel[client]) {
		gB_ShowingInfoPanel[client] = false;
		CPrintToChat(client, "%t %t", "KZ_Tag", "InfoPanel_Disable");
	}
	else {
		gB_ShowingInfoPanel[client] = true;
		CPrintToChat(client, "%t %t", "KZ_Tag", "InfoPanel_Enable");
	}
}

void ToggleShowWeapon(int client) {
	if (gB_ShowingWeapon[client]) {
		gB_ShowingWeapon[client] = false;
		CPrintToChat(client, "%t %t", "KZ_Tag", "ShowWeapon_Disable");
	}
	else {
		gB_ShowingWeapon[client] = true;
		CPrintToChat(client, "%t %t", "KZ_Tag", "ShowWeapon_Enable");
	}
	SetDrawViewModel(client, gB_ShowingWeapon[client]);
}

void ToggleShowKeys(int client) {
	if (gB_ShowingKeys[client]) {
		gB_ShowingKeys[client] = false;
		CPrintToChat(client, "%t %t", "KZ_Tag", "ShowKeys_Disable");
	}
	else {
		gB_ShowingKeys[client] = true;
		CPrintToChat(client, "%t %t", "KZ_Tag", "ShowKeys_Enable");
	}
}

void ToggleAutoRestart(int client) {
	if (gB_AutoRestart[client]) {
		gB_AutoRestart[client] = false;
		CPrintToChat(client, "%t %t", "KZ_Tag", "AutoRestart_Disable");
	}
	else {
		gB_AutoRestart[client] = true;
		CPrintToChat(client, "%t %t", "KZ_Tag", "AutoRestart_Enable");
	}
}

void ToggleSlayOnEnd(int client) {
	if (gB_SlayOnEnd[client]) {
		gB_SlayOnEnd[client] = false;
		CPrintToChat(client, "%t %t", "KZ_Tag", "SlayOnEnd_Disable");
	}
	else {
		gB_SlayOnEnd[client] = true;
		CPrintToChat(client, "%t %t", "KZ_Tag", "SlayOnEnd_Enable");
	}
}



/*===============================  Splits  ===============================*/

void SplitsSetup(int client) {
	gI_Splits[client] = 0;
	gF_SplitRunTime[client] = 0.0;
	gF_SplitGameTime[client] = 0.0;
}

void SplitsReset(int client) {
	if (IsClientInGame(client) && gB_HasStartedThisMap[client] && gI_Splits[client] != 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Split_Reset");
	}
	gI_Splits[client] = 0;
	gF_SplitRunTime[client] = 0.0;
	gF_SplitGameTime[client] = 0.0;
}

void SplitsMake(int client) {
	if ((GetGameTime() - gF_SplitGameTime[client]) < MINIMUM_SPLIT_TIME) {  // Ignore split spam
		CloseTeleportMenu(client);
		return;
	}
	
	gI_Splits[client]++;
	if (gB_TimerRunning[client]) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Split_Make", 
			gI_Splits[client], 
			FormatTimeFloat(gF_CurrentTime[client] - gF_SplitRunTime[client]), 
			FormatTimeFloat(gF_CurrentTime[client]));
	}
	else {
		if (gI_Splits[client] == 1) {
			CPrintToChat(client, "%t %t", "KZ_Tag", "Split_MakeFirst");
		}
		else {
			CPrintToChat(client, "%t %t", "KZ_Tag", "Split_Make_TimerStopped", 
				FormatTimeFloat(GetGameTime() - gF_SplitGameTime[client]));
		}
	}
	gF_SplitRunTime[client] = gF_CurrentTime[client];
	gF_SplitGameTime[client] = GetGameTime();
	
	CloseTeleportMenu(client);
}



/*===============================  Block Checkpoints on B-Hop Blocks  ===============================*/

void NoBhopBlockCPSetup(int client) {
	gI_JustTouchedTrigMulti[client] = 0;
}

public void OnTrigMultiStartTouch(const char[] name, int caller, int activator, float delay) {
	gI_JustTouchedTrigMulti[activator]++;
	CreateTimer(BHOP_BLOCK_DETECTION_PERIOD, TrigMultiStartTouchDelayed, activator);
}

public Action TrigMultiStartTouchDelayed(Handle timer, int client) {
	if (IsValidClient(client)) {
		if (gI_JustTouchedTrigMulti[client] > 0) {
			gI_JustTouchedTrigMulti[client]--;
		}
	}
	return Plugin_Continue;
}

bool JustTouchedBhopBlock(int client) {
	// If just touched trigger_multiple and landed within 0.2 seconds ago
	if ((gI_JustTouchedTrigMulti[client] > 0)
		 && (GetGameTickCount() - g_MovementPlayer[client].landingTick) < (BHOP_BLOCK_DETECTION_PERIOD / GetTickInterval())) {
		return true;
	}
	return false;
} 