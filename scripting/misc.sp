/*	misc.sp

*/


void AddCommandListeners() {
	AddCommandListener(CommandJoinTeam, "jointeam");
	SetupOtherMenuListeners();
}

bool IsValidClient(int client) {
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client)) {
		return false;
	}
	return true;
}

void ResetClientVariables(int client) {
	TimerResetClientVariables(client);
	g_clientHidingPlayers[client] = false;
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

int GetRunType(int client) {
	// Returns 0 for PRO run
	if (g_clientTeleportsUsed[client] == 0) {
		return 0;
	}
	// Returns 1 for TP run
	else {
		return 1;
	}
}

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

public Action CleanHUD(Handle timer, int client) {
	if (IsValidClient(client)) {
		// Hides radar
		int clientEntFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
		SetEntProp(client, Prop_Send, "m_iHideHUD", clientEntFlags | (1 << 12));
	}
}

int GetSpectatedPlayer(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

void TeleportToOtherPlayer(client, target)
{
	float targetOrigin[3];
	float targetAngles[3];
	char targetName[MAX_NAME_LENGTH];
	
	GetClientAbsOrigin(target, targetOrigin);
	GetClientEyeAngles(target, targetAngles);
	GetClientName(target, targetName, MAX_NAME_LENGTH);
	
	TeleportEntity(client, targetOrigin, targetAngles, Float: { 0.0, 0.0, -100.0 } );
	PrintToChat(client, "[KZ] You have teleported to %s.", targetName);
}