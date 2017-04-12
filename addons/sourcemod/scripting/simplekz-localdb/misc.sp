/*	misc.sp

	Miscellaneous functions.
*/


void SetupKZMethodmaps() {
	for (int client = 1; client <= MaxClients; client++) {
		g_KZPlayer[client] = new KZPlayer(client);
	}
}

void GetMapName() {
	char map[64];
	GetCurrentMap(map, sizeof(map));
	// Get just the map name (e.g. remove workshop/id/ prefix)
	char mapPieces[5][64];
	int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(gC_CurrentMap, sizeof(gC_CurrentMap), "%s", mapPieces[lastPiece - 1]);
	String_ToLower(gC_CurrentMap, gC_CurrentMap, sizeof(gC_CurrentMap));
}

void CompileRegexes() {
	gRE_BonusStartButton = CompileRegex("^climb_bonus(\\d+)_startbutton$");
} 