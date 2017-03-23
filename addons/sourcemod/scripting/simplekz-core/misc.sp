/*	misc.sp

	Miscellaneous functions.
*/


/*===============================  General  ===============================*/

bool IsValidClient(int client) {
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

float FloatMax(float a, float b) {
	if (a > b) {
		return a;
	}
	return b;
}

void String_ToLower(const char[] input, char[] output, int size) {
	size--;
	int i = 0;
	while (input[i] != '\0' && i < size) {
		output[i] = CharToLower(input[i]);
		i++;
	}
	output[i] = '\0';
}

void SetupMovementMethodmaps() {
	for (int client = 1; client <= MaxClients; client++) {
		g_MovementPlayer[client] = new MovementPlayer(client);
	}
}

void CompileRegexes() {
	gRE_BonusStartButton = CompileRegex("^climb_bonus(\\d+)_startbutton$");
	gRE_BonusEndButton = CompileRegex("^climb_bonus(\\d+)_endbutton$");
}

void AddCommandListeners() {
	AddCommandListener(CommandJoinTeam, "jointeam");
	// Block radio commands
	for (int i = 0; i < sizeof(gC_RadioCommands); i++) {
		AddCommandListener(CommandBlock, gC_RadioCommands[i]);
	}
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



/*===============================  Map  ===============================*/

void SetupMap() {
	char map[64];
	GetCurrentMap(map, sizeof(map));
	// Get just the map name (e.g. remove workshop/id/ prefix)
	char mapPieces[5][64];
	int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(gC_CurrentMap, sizeof(gC_CurrentMap), "%s", mapPieces[lastPiece - 1]);
	String_ToLower(gC_CurrentMap, gC_CurrentMap, sizeof(gC_CurrentMap));
	// Check for kzpro_ tag
	char mapPrefix[1][64];
	ExplodeString(gC_CurrentMap, "_", mapPrefix, sizeof(mapPrefix), sizeof(mapPrefix[]));
	gB_CurrentMapIsKZPro = StrEqual(mapPrefix[0], "kzpro");
	
	// Precache stuff
	PrecacheModels();
}

void PrecacheModels() {
	gI_GlowSprite = PrecacheModel("materials/sprites/bluelaser1.vmt", true); // Measure
	PrecachePlayerModels();
}

void PrecachePlayerModels() {
	GetConVarString(gCV_PlayerModelT, gC_PlayerModelT, sizeof(gC_PlayerModelT));
	GetConVarString(gCV_PlayerModelCT, gC_PlayerModelCT, sizeof(gC_PlayerModelCT));
	
	PrecacheModel(gC_PlayerModelT, true);
	AddFileToDownloadsTable(gC_PlayerModelT);
	PrecacheModel(gC_PlayerModelCT, true);
	AddFileToDownloadsTable(gC_PlayerModelCT);
}



/*===============================  Client  ===============================*/

void SetupClient(int client) {
	SetDefaultOptions(client);
	TimerSetup(client);
	UpdatePistolMenu(client);
	UpdateMeasureMenu(client);
	MeasureResetPos(client);
	UpdateOptionsMenu(client);
	NoBhopBlockCPSetup(client);
	Call_SimpleKZ_OnClientSetup(client);
}

void PrintConnectMessage(int client) {
	char name[MAX_NAME_LENGTH], clientIP[32], country[45];
	GetClientName(client, name, MAX_NAME_LENGTH);
	GetClientIP(client, clientIP, sizeof(clientIP));
	if (!GeoipCountry(clientIP, country, sizeof(country))) {
		country = "Unknown";
	}
	CPrintToChatAll("%T", "Client Connection Message", client, name, country);
}

void PrintDisconnectMessage(int client, const char[] reason) {
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, MAX_NAME_LENGTH);
	CPrintToChatAll("%T", "Client Disconnection Message", client, name, reason);
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
			gB_HasSavedPosition[client] = false;
			if (gB_Paused[client]) {
				FreezePlayer(client);
			}
		}
		else {
			// The player will be teleported to the spawn point, so force stop their timer
			SimpleKZ_ForceStopTimer(client);
		}
	}
	CloseTeleportMenu(client);
}

void SetDrawViewModel(int client, bool drawViewModel) {
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", drawViewModel);
}

void GotoPlayer(int client, int target)
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
	CPrintToChat(client, "%t %t", "KZ Prefix", "Goto Success", target);
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

KZTimeType GetCurrentTimeType(int client) {
	if (gI_TeleportsUsed[client] == 0) {
		return KZTimeType_Pro;
	}
	else {
		return KZTimeType_Normal;
	}
}

void UpdatePlayerModel(int client) {
	if (GetClientTeam(client) == CS_TEAM_T) {
		SetEntityModel(client, gC_PlayerModelT);
	}
	else if (GetClientTeam(client) == CS_TEAM_CT) {
		SetEntityModel(client, gC_PlayerModelCT);
	}
}

void GivePlayerPistol(int client, KZPistol pistol) {
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) {
		return;
	}
	
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

public Action CleanHUD(Handle timer, int client) {
	if (IsValidClient(client)) {
		// (1 << 12) Hide Radar
		// (1 << 13) Hide Round Timer
		int clientEntFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
		SetEntProp(client, Prop_Send, "m_iHideHUD", clientEntFlags | (1 << 12) + (1 << 13));
	}
	return Plugin_Continue;
}

public Action SlayPlayer(Handle timer, int client) {
	if (IsValidClient(client)) {
		ForcePlayerSuicide(client);
	}
	return Plugin_Continue;
}

public Action ZeroVelocity(Handle timer, int client) {
	if (IsValidClient(client)) {
		g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, -0.0 } ));
		g_MovementPlayer[client].SetBaseVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	}
	return Plugin_Continue;
}



/*===============================  Block Checkpoints on B-Hop Blocks  ===============================*/

void NoBhopBlockCPSetup(int client) {
	gI_JustTouchedTrigMulti[client] = 0;
}

public void OnTrigMultiStartTouch(const char[] name, int caller, int activator, float delay) {
	if (IsValidClient(activator)) {
		gI_JustTouchedTrigMulti[activator]++;
		CreateTimer(TIME_BHOP_TRIGGER_DETECTION, TrigMultiStartTouchDelayed, activator);
	}
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
		 && (GetGameTickCount() - g_MovementPlayer[client].landingTick) < (TIME_BHOP_TRIGGER_DETECTION / GetTickInterval())) {
		return true;
	}
	return false;
}



/*===============================  Timer Text  ===============================*/

void UpdateTimerText(int client) {
	if (g_TimerText[client] == KZTimerText_Disabled) {
		return;
	}
	
	switch (g_TimerText[client]) {
		case KZTimerText_Disabled: {
			return;
		}
		case KZTimerText_Top: {
			SetHudTextParams(-1.0, 0.013, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
		}
		case KZTimerText_Bottom: {
			SetHudTextParams(-1.0, 0.957, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
		}
	}
	
	if (IsPlayerAlive(client) && gB_TimerRunning[client]) {
		ShowHudText(client, 0, SimpleKZ_FormatTime(gF_CurrentTime[client]));
	}
	else {
		int spectatedPlayer = GetSpectatedPlayer(client);
		if (IsValidClient(spectatedPlayer) && gB_TimerRunning[spectatedPlayer]) {
			ShowHudText(client, 0, SimpleKZ_FormatTime(gF_CurrentTime[spectatedPlayer]));
		}
	}
} 