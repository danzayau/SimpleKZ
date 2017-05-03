/*
	Timer
	
	Used to record how long the player takes to complete map courses.
*/

#define STYLE_STANDARD_SOUND_START "buttons/button9.wav"
#define STYLE_STANDARD_SOUND_END "buttons/bell1.wav"
#define STYLE_LEGACY_SOUND_START "buttons/button3.wav"
#define STYLE_LEGACY_SOUND_END "buttons/button3.wav"
#define STYLE_COMPETITIVE_SOUND_START "buttons/button9.wav"
#define STYLE_COMPETITIVE_SOUND_END "buttons/bell1.wav"

void TimerSetupClient(int client)
{
	gB_TimerRunning[client] = false;
	gB_Paused[client] = false;
	gB_HasStartedThisMap[client] = false;
	gB_HasEndedThisMap[client] = false;
	TimerReset(client);
}

void TimerOnPlayerRunCmd(int client)
{
	if (IsPlayerAlive(client) && gB_TimerRunning[client] && !gB_Paused[client])
	{
		gF_CurrentTime[client] += GetTickInterval();
	}
}

// Starts the player's timer for the specified course.
void TimerStart(int client, int course)
{
	// Have to be on ground, not noclipping, and haven't just started timer
	if (!g_KZPlayer[client].onGround || g_KZPlayer[client].noclipping
		 || (gB_TimerRunning[client] && gF_CurrentTime[client] < 0.1))
	{
		return;
	}
	
	Resume(client);
	TimerReset(client);
	gB_TimerRunning[client] = true;
	gI_LastCourseStarted[client] = course;
	
	gB_HasStartedThisMap[client] = true;
	gI_LastCourseStarted[client] = course;
	g_KZPlayer[client].GetOrigin(gF_StartOrigin[client]);
	g_KZPlayer[client].GetEyeAngles(gF_StartAngles[client]);
	
	PlayTimerStartSound(client);
	
	Call_SKZ_OnTimerStart(client, course);
}

// Tries to end the player's timer for the specified course.
// It won't do anything if the player's isn't on a time on that course.
void TimerEnd(int client, int course)
{
	if (!gB_TimerRunning[client] || course != gI_LastCourseStarted[client])
	{
		return;
	}
	
	gB_TimerRunning[client] = false;
	
	gB_HasEndedThisMap[client] = true;
	
	if (!gB_SKZLocalRanks)
	{
		PrintEndTimeString(client);
	}
	PlayTimerEndSound(client);
	
	if (g_SlayOnEnd[client] == KZSlayOnEnd_Enabled)
	{
		CreateTimer(3.0, Timer_SlayPlayer, client);
	}
	
	Call_SKZ_OnTimerEnd(client, course);
}



/*===============================  Static Functions  ===============================*/

static void TimerReset(int client)
{
	gF_CurrentTime[client] = 0.0;
	gF_LastResumeTime[client] = 0.0;
	gB_HasPausedInThisRun[client] = false;
	gB_HasResumedInThisRun[client] = false;
	gI_CheckpointCount[client] = 0;
	gI_TeleportsUsed[client] = 0;
	gF_LastCheckpointTime[client] = 0.0;
	gF_LastGoCheckTime[client] = 0.0;
	gF_LastGoCheckWastedTime[client] = 0.0;
	gF_LastUndoTime[client] = 0.0;
	gF_LastUndoWastedTime[client] = 0.0;
	gF_LastTeleportToStartTime[client] = 0.0;
	gF_LastTeleportToStartWastedTime[client] = 0.0;
	gF_WastedTime[client] = 0.0;
	gB_HasSavedPosition[client] = false;
}

static void PrintEndTimeString(int client)
{
	if (gI_LastCourseStarted[client] == 0)
	{
		switch (GetCurrentTimeType(client))
		{
			case KZTimeType_Nub:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map (Nub)", 
					client, SKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
			case KZTimeType_Pro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map (Pro)", 
					client, SKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
		}
	}
	else
	{
		switch (GetCurrentTimeType(client))
		{
			case KZTimeType_Nub:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus (Nub)", 
					client, gI_LastCourseStarted[client], SKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
			case KZTimeType_Pro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus (Pro)", 
					client, gI_LastCourseStarted[client], SKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
		}
	}
}

static void PlayTimerStartSound(int client)
{
	switch (g_Style[client])
	{
		case KZStyle_Standard:
		{
			EmitSoundToClient(client, STYLE_STANDARD_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_STANDARD_SOUND_START);
		}
		case KZStyle_Legacy:
		{
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_START);
		}
		case KZStyle_Competitive:
		{
			EmitSoundToClient(client, STYLE_COMPETITIVE_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_COMPETITIVE_SOUND_START);
		}
	}
}

static void PlayTimerEndSound(int client)
{
	switch (g_Style[client])
	{
		case KZStyle_Standard:
		{
			EmitSoundToClient(client, STYLE_STANDARD_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_STANDARD_SOUND_END);
		}
		case KZStyle_Legacy:
		{
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_END);
		}
		case KZStyle_Competitive:
		{
			EmitSoundToClient(client, STYLE_COMPETITIVE_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_COMPETITIVE_SOUND_START);
		}
	}
} 