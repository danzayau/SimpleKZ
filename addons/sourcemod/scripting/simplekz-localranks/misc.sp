/*
	Miscellaneous
	
	Miscellaneous functions.
*/

#define SOUND_NEW_RECORD "physics/glass/glass_bottle_break2.wav"

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

void AnnounceNewTime(
	int client, 
	int course, 
	KZStyle style, 
	float runTime, 
	int teleportsUsed, 
	bool firstTime, 
	float pbDiff, 
	int rank, 
	int maxRank, 
	bool firstTimePro, 
	float pbDiffPro, 
	int rankPro, 
	int maxRankPro)
{
	// Main Course
	if (course == 0)
	{
		// Main Course PRO Times
		if (teleportsUsed == 0)
		{
			if (firstTimePro)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Time - First Time (Pro)", 
					client, SKZ_FormatTime(runTime), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else if (pbDiffPro < 0)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Time - Beat PB (Pro)", 
					client, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiffPro)), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Time - Miss PB (Pro)", 
					client, SKZ_FormatTime(runTime), SKZ_FormatTime(pbDiffPro), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
		}
		// Main Course NUB Times
		else
		{
			if (firstTime)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Time - First Time", 
					client, SKZ_FormatTime(runTime), rank, maxRank, gC_StylePhrases[style]);
			}
			else if (pbDiff < 0)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Time - Beat PB", 
					client, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiff)), rank, maxRank, gC_StylePhrases[style]);
			}
			else
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Time - Miss PB", 
					client, SKZ_FormatTime(runTime), SKZ_FormatTime(pbDiff), rank, maxRank, gC_StylePhrases[style]);
			}
		}
	}
	// Bonus Course
	else
	{
		// Bonus Course PRO Times
		if (teleportsUsed == 0)
		{
			if (firstTimePro)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Bonus Time - First Time (Pro)", 
					client, course, SKZ_FormatTime(runTime), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else if (pbDiffPro < 0)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Bonus Time - Beat PB (Pro)", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiffPro)), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Bonus Time - Miss PB (Pro)", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(pbDiffPro), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
		}
		// Bonus Course NUB Times
		else
		{
			if (firstTime)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Bonus Time - First Time", 
					client, course, SKZ_FormatTime(runTime), rank, maxRank, gC_StylePhrases[style]);
			}
			else if (pbDiff < 0)
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Bonus Time - Beat PB", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiff)), rank, maxRank, gC_StylePhrases[style]);
			}
			else
			{
				CPrintToChatAll("%t %t", 
					"KZ Prefix", 
					"New Bonus Time - Miss PB", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(pbDiff), rank, maxRank, gC_StylePhrases[style]);
			}
		}
		
	}
}

void AnnounceNewRecord(int client, int course, KZStyle style, KZRecordType recordType)
{
	if (course == 0)
	{
		switch (recordType)
		{
			case KZRecordType_Nub:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "New Record (Nub)", client, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "New Record (Pro)", client, gC_StylePhrases[style]);
			}
			case KZRecordType_NubAndPro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "New Record (Nub and Pro)", client, gC_StylePhrases[style]);
			}
		}
	}
	else
	{
		switch (recordType)
		{
			case KZRecordType_Nub:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "New Bonus Record (Nub)", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "New Bonus Record (Pro)", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_NubAndPro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "New Bonus Record (Nub and Pro)", client, course, course, gC_StylePhrases[style]);
			}
		}
	}
}

void PlayNewRecordSound()
{
	EmitSoundToAll(SOUND_NEW_RECORD);
} 