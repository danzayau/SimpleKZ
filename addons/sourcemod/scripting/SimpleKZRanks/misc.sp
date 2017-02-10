/*	misc.sp

	Miscellaneous functions.
*/

bool IsValidClient(int client) {
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

void SetupClient(int client) {
	GetClientSteamID(client);
	AddItemsPlayerTopMenu(client);
}

void GetClientSteamID(int client) {
	GetClientAuthId(client, AuthId_Steam2, gC_SteamID[client], 24, true);
}

void UpdateCurrentMap() {
	// Get just the map name (e.g. remove workshop/id/ prefix)
	GetCurrentMap(gC_CurrentMap, sizeof(gC_CurrentMap));
	char mapPieces[5][64];
	int lastPiece = ExplodeString(gC_CurrentMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(gC_CurrentMap, sizeof(gC_CurrentMap), "%s", mapPieces[lastPiece - 1]);
	String_ToLower(gC_CurrentMap, gC_CurrentMap, sizeof(gC_CurrentMap));
}

void FakePrecacheSound(const char[] relativeSoundPath) {
	AddToStringTable(FindStringTable("soundprecache"), relativeSoundPath);
}

void EmitSoundToClientSpectators(int client, const char[] sound) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && GetSpectatedPlayer(i) == client) {
			EmitSoundToClient(i, sound);
		}
	}
}

int GetSpectatedPlayer(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
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

void String_ToLower(const char[] input, char[] output, int size) {
	size--;
	int i = 0;
	while (input[i] != '\0' && i < size) {
		output[i] = CharToLower(input[i]);
		i++;
	}
	output[i] = '\0';
} 