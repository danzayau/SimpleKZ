/*
	Miscellaneous
	
	Miscellaneous functions.
*/

// TO-DO: Replace with sound config
#define FULL_SOUNDPATH_BEAT_RECORD "sound/SimpleKZ/beatrecord1.mp3"
#define REL_SOUNDPATH_BEAT_RECORD "*/SimpleKZ/beatrecord1.mp3"
#define FULL_SOUNDPATH_BEAT_MAP "sound/SimpleKZ/beatmap1.mp3"
#define REL_SOUNDPATH_BEAT_MAP "*/SimpleKZ/beatmap1.mp3"



/*===============================  Helper Functions  ===============================*/

int GetSpectatedPlayer(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

void EmitSoundToClientSpectators(int client, const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetSpectatedPlayer(i) == client)
		{
			EmitSoundToClient(i, sound);
		}
	}
}

// Sets the player's MVP stars as the percentage PRO completion on the server's default style
void CompletionMVPStarsUpdate(int client)
{
	DB_GetCompletion(client, GetSteamAccountID(client), SKZ_GetDefaultStyle(), false);
}

void CompletionMVPStarsUpdateAll()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			CompletionMVPStarsUpdate(client);
		}
	}
}



/*===============================  Announcements  ===============================*/

// Print new record message to chat and play sound
void AnnounceNewRecord(int client, int course, KZStyle style, KZRecordType recordType)
{
	if (course == 0)
	{
		switch (recordType)
		{
			case KZRecordType_Map:
			{
				CPrintToChatAll(" %t", "New Record - Map", client, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				CPrintToChatAll(" %t", "New Record - Pro", client, gC_StylePhrases[style]);
			}
			case KZRecordType_MapAndPro:
			{
				CPrintToChatAll(" %t", "New Record - Map and Pro", client, gC_StylePhrases[style]);
			}
		}
	}
	else
	{
		switch (recordType)
		{
			case KZRecordType_Map:
			{
				CPrintToChatAll(" %t", "New Bonus Record - Map", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				CPrintToChatAll(" %t", "New Bonus Record - Pro", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_MapAndPro:
			{
				CPrintToChatAll(" %t", "New Bonus Record - Map and Pro", client, course, course, gC_StylePhrases[style]);
			}
		}
	}
	EmitSoundToAll(REL_SOUNDPATH_BEAT_RECORD);
}

// Print new PB message to chat and play sound if first time beating the map PRO
void AnnounceNewPersonalBest(int client, int course, KZStyle style, KZTimeType timeType, bool firstTime, float improvement, int rank, int maxRank)
{
	if (course == 0)
	{
		switch (timeType)
		{
			case KZTimeType_Normal:
			{
				// Only printing MAP time improvement to the achieving player (instead of ALL) due to spam complaints
				if (firstTime)
				{
					CPrintToChat(client, " %t", "New PB - First Time", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else
				{
					CPrintToChat(client, " %t", "New PB - Improve", client, SKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case KZTimeType_Pro:
			{
				if (firstTime)
				{
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
					CompletionMVPStarsUpdate(client);
					EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
					EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
				}
				else
				{
					CPrintToChatAll(" %t", "New PB - Improve (Pro)", client, SKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
		}
	}
	else
	{
		switch (timeType)
		{
			case KZTimeType_Normal:
			{
				// Only printing MAP time improvement to the achieving player (instead of ALL) due to spam complaints
				if (firstTime)
				{
					CPrintToChat(client, " %t", "New PB - First Time", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else
				{
					CPrintToChat(client, " %t", "New PB - Improve", client, SKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case KZTimeType_Pro:
			{
				if (firstTime)
				{
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
					EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
					EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
				}
				else
				{
					CPrintToChatAll(" %t", "New PB - Improve (Pro)", client, SKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
		}
	}
} 