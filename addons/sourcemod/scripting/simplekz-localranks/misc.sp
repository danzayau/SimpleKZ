/*
	Miscellaneous
	
	Miscellaneous functions.
*/



#define SOUND_NEW_RECORD "physics/glass/glass_bottle_break2.wav"

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

void AnnounceNewTime(
	int client, 
	int course, 
	int style, 
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
				SKZ_PrintToChatAll(true, "%t", "New Time - First Time (Pro)", 
					client, SKZ_FormatTime(runTime), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else if (pbDiffPro < 0)
			{
				SKZ_PrintToChatAll(true, "%t", "New Time - Beat PB (Pro)", 
					client, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiffPro)), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else
			{
				SKZ_PrintToChatAll(true, "%t", "New Time - Miss PB (Pro)", 
					client, SKZ_FormatTime(runTime), SKZ_FormatTime(pbDiffPro), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
		}
		// Main Course NUB Times
		else
		{
			if (firstTime)
			{
				SKZ_PrintToChatAll(true, "%t", "New Time - First Time", 
					client, SKZ_FormatTime(runTime), rank, maxRank, gC_StylePhrases[style]);
			}
			else if (pbDiff < 0)
			{
				SKZ_PrintToChatAll(true, "%t", "New Time - Beat PB", 
					client, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiff)), rank, maxRank, gC_StylePhrases[style]);
			}
			else
			{
				SKZ_PrintToChatAll(true, "%t", "New Time - Miss PB", 
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
				SKZ_PrintToChatAll(true, "%t", "New Bonus Time - First Time (Pro)", 
					client, course, SKZ_FormatTime(runTime), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else if (pbDiffPro < 0)
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Time - Beat PB (Pro)", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiffPro)), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
			else
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Time - Miss PB (Pro)", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(pbDiffPro), rankPro, maxRankPro, gC_StylePhrases[style]);
			}
		}
		// Bonus Course NUB Times
		else
		{
			if (firstTime)
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Time - First Time", 
					client, course, SKZ_FormatTime(runTime), rank, maxRank, gC_StylePhrases[style]);
			}
			else if (pbDiff < 0)
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Time - Beat PB", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(FloatAbs(pbDiff)), rank, maxRank, gC_StylePhrases[style]);
			}
			else
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Time - Miss PB", 
					client, course, SKZ_FormatTime(runTime), SKZ_FormatTime(pbDiff), rank, maxRank, gC_StylePhrases[style]);
			}
		}
		
	}
}

void AnnounceNewRecord(int client, int course, int style, KZRecordType recordType)
{
	if (course == 0)
	{
		switch (recordType)
		{
			case KZRecordType_Nub:
			{
				SKZ_PrintToChatAll(true, "%t", "New Record (Nub)", client, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				SKZ_PrintToChatAll(true, "%t", "New Record (Pro)", client, gC_StylePhrases[style]);
			}
			case KZRecordType_NubAndPro:
			{
				SKZ_PrintToChatAll(true, "%t", "New Record (Nub and Pro)", client, gC_StylePhrases[style]);
			}
		}
	}
	else
	{
		switch (recordType)
		{
			case KZRecordType_Nub:
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Record (Nub)", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_Pro:
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Record (Pro)", client, course, gC_StylePhrases[style]);
			}
			case KZRecordType_NubAndPro:
			{
				SKZ_PrintToChatAll(true, "%t", "New Bonus Record (Nub and Pro)", client, course, course, gC_StylePhrases[style]);
			}
		}
	}
}

void PlayNewRecordSound()
{
	EmitSoundToAll(SOUND_NEW_RECORD);
} 