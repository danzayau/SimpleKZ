/*
	Miscellaneous
	
	Miscellaneous functions.
*/



/*===============================  Helper Functions  ===============================*/

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
			case KZRecordType_Nub:
			{
				CPrintToChatAll(" %t", "New Record (Nub)", client, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				CPrintToChatAll(" %t", "New Record (Pro)", client, gC_StylePhrases[style]);
			}
			case KZRecordType_NubAndPro:
			{
				CPrintToChatAll(" %t", "New Record (Nub and Pro)", client, gC_StylePhrases[style]);
			}
		}
	}
	else
	{
		switch (recordType)
		{
			case KZRecordType_Nub:
			{
				CPrintToChatAll(" %t", "New Bonus Record (Nub)", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				CPrintToChatAll(" %t", "New Bonus Record (Pro)", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_NubAndPro:
			{
				CPrintToChatAll(" %t", "New Bonus Record (Nub and Pro)", client, course, course, gC_StylePhrases[style]);
			}
		}
	}
}

// Print new PB message to chat and play sound if first time beating the map PRO
void AnnounceNewPersonalBest(int client, int course, KZStyle style, KZTimeType timeType, bool firstTime, float improvement, int rank, int maxRank)
{
	if (course == 0)
	{
		switch (timeType)
		{
			case KZTimeType_Nub:
			{
				// Only printing MAP time improvement to the achieving player (instead of ALL) due to spam complaints
				if (firstTime)
				{
					CPrintToChat(client, " %t", "New PB - First Time (Nub)", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else
				{
					CPrintToChat(client, " %t", "New PB - Improve (Nub)", client, SKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case KZTimeType_Pro:
			{
				if (firstTime)
				{
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
					CompletionMVPStarsUpdate(client);
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
			case KZTimeType_Nub:
			{
				// Only printing MAP time improvement to the achieving player (instead of ALL) due to spam complaints
				if (firstTime)
				{
					CPrintToChat(client, " %t", "New PB - First Time (Nub)", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else
				{
					CPrintToChat(client, " %t", "New PB - Improve (Nub)", client, SKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case KZTimeType_Pro:
			{
				if (firstTime)
				{
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else
				{
					CPrintToChatAll(" %t", "New PB - Improve (Pro)", client, SKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
		}
	}
} 