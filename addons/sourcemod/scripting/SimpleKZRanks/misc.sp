/*	misc.sp

	Miscellaneous functions.
*/

bool IsValidClient(int client) {
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
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

void SetupClient(int client) {
	AddItemsPlayerTopMenu(client);
}

void UpdateCompletionMVPStars(int client) {
	DB_GetCompletion(client, client, SimpleKZ_GetDefaultStyle(), false);
}

int GetSpectatedPlayer(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

void SetupMap() {
	// Get just the map name (e.g. remove workshop/id/ prefix)
	GetCurrentMap(gC_CurrentMap, sizeof(gC_CurrentMap));
	char mapPieces[5][64];
	int lastPiece = ExplodeString(gC_CurrentMap, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(gC_CurrentMap, sizeof(gC_CurrentMap), "%s", mapPieces[lastPiece - 1]);
	String_ToLower(gC_CurrentMap, gC_CurrentMap, sizeof(gC_CurrentMap));
	
	DB_SetupMap();
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