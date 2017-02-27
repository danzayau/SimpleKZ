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

void AnnounceNewRecord(int client, int course, MovementStyle style, RecordType recordType) {
	// Print new record message to chat and play sound
	if (course == 0) {
		switch (recordType) {
			case RecordType_Map: {
				CPrintToChatAll(" %t", "New Record - Map", client, gC_StylePhrases[style]);
			}
			case RecordType_Pro: {
				CPrintToChatAll(" %t", "New Record - Pro", client, gC_StylePhrases[style]);
			}
			case RecordType_MapAndPro: {
				CPrintToChatAll(" %t", "New Record - Map and Pro", client, gC_StylePhrases[style]);
			}
		}
		EmitSoundToAll(REL_SOUNDPATH_BEAT_RECORD);
	}
	else {
		switch (recordType) {
			case RecordType_Map: {
				CPrintToChatAll(" %t", "New Bonus Record - Map", client, course, gC_StylePhrases[style]);
			}
			case RecordType_Pro: {
				CPrintToChatAll(" %t", "New Bonus Record - Pro", client, course, gC_StylePhrases[style]);
			}
			case RecordType_MapAndPro: {
				CPrintToChatAll(" %t", "New Bonus Record - Map and Pro", client, course, gC_StylePhrases[style]);
			}
		}
	}
}

void AnnounceNewPersonalBest(int client, int course, MovementStyle style, TimeType timeType, bool firstTime, float improvement, int rank, int maxRank) {
	// Print new PB message to chat and play sound if first time beating the map PRO
	if (course == 0) {
		switch (timeType) {
			case TimeType_Normal: {
				// Only printing MAP time improvement to the achieving player due to spam complaints
				if (firstTime) {
					CPrintToChat(client, " %t", "New PB - First Time", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else {
					CPrintToChat(client, " %t", "New PB - Improve", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case TimeType_Pro: {
				if (firstTime) {
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
					UpdateCompletionMVPStars(client);
					EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
					EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
				}
				else {
					CPrintToChatAll(" %t", "New PB - Improve (Pro)", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
		}
	}
	else {
		switch (timeType) {
			case TimeType_Normal: {
				// Only printing MAP time improvement to the achieving player due to spam complaints
				if (firstTime) {
					CPrintToChat(client, " %t", "New PB - First Time", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else {
					CPrintToChat(client, " %t", "New PB - Improve", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case TimeType_Pro: {
				if (firstTime) {
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
					EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
					EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
				}
				else {
					CPrintToChatAll(" %t", "New PB - Improve (Pro)", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
		}
	}
} 