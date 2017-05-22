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
#define SOUND_TIMER_STOP "buttons/button18.wav"

static bool timerRunning[MAXPLAYERS + 1];
static float currentTime[MAXPLAYERS + 1];
static int currentCourse[MAXPLAYERS + 1];
static bool hasStartedTimerThisMap[MAXPLAYERS + 1];
static bool hasEndedTimerThisMap[MAXPLAYERS + 1];



// =========================  PUBLIC  ========================= //

bool GetTimerRunning(int client)
{
	return timerRunning[client];
}

float GetCurrentTime(int client)
{
	return currentTime[client];
}

int GetCurrentCourse(int client)
{
	return currentCourse[client];
}

bool GetHasStartedTimerThisMap(int client)
{
	return hasStartedTimerThisMap[client];
}

int GetCurrentTimeType(int client)
{
	if (GetTeleportCount(client) == 0)
	{
		return TimeType_Pro;
	}
	return TimeType_Nub;
}

void TimerStart(int client, int course, bool allowOffGround = false)
{
	if (!IsPlayerAlive(client)
		 || !Movement_GetOnGround(client) && !allowOffGround
		 || Movement_GetMoveType(client) != MOVETYPE_WALK
		 || timerRunning[client] && currentTime[client] < 0.1)
	{
		return;
	}
	
	int style = GetOption(client, Option_Style);
	
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnTimerStart(client, course, style, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// Start Timer
	currentTime[client] = 0.0;
	timerRunning[client] = true;
	currentCourse[client] = course;
	hasStartedTimerThisMap[client] = true;
	PlayTimerStartSound(client);
	SetFragsToTimer(client);
	
	
	// Call Post Forward
	Call_SKZ_OnTimerStart_Post(client, course, style);
}

void SetFragsToTimer(int client)
{
	// Creates a timer that gets timer for client, repeats until Plugin_Stop is reached.
	CreateTimer(0.0, GetTimer, GetClientSerial(client), TIMER_REPEAT);
}

public Action GetTimer(Handle timer, any serial)
{
	int client = GetClientFromSerial(serial);
	
	/* If no client, timer isn't running, so it resets and stops counting.
	* If timer not running, frags (checkpoints) resets to 0 and stops running.
	* If timer not running, deaths(teleports) resets to 0 and stop running.
	*/
	if (client == 0 || timerRunning[client] == false)
	{
		return Plugin_Stop;
	}
	
	
	// Sets frags as a count for player's time.
 	SetEntProp(client, Prop_Data, "m_iFrags", RoundToFloor(currentTime[client]));
 	
 	// Continues plugin indefinitely. Plugin_Stop must be used later otherwise it results in a memory leak.
 	return Plugin_Continue;
}


void TimerEnd(int client, int course)
{
	if (!IsPlayerAlive(client)
		 || !timerRunning[client]
		 || course != currentCourse[client])
	{
		return;
	}
	
	int style = GetOption(client, Option_Style);
	float time = GetCurrentTime(client);
	int teleportsUsed = GetTeleportCount(client);
	float theoreticalTime = GetCurrentTime(client) - GetWastedTime(client);
	
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnTimerEnd(client, course, style, time, teleportsUsed, theoreticalTime, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// End Timer
	timerRunning[client] = false;
	hasEndedTimerThisMap[client] = true;
	PlayTimerEndSound(client);
	if (!gB_SKZLocalRanks)
	{
		PrintEndTimeString(client);
	}
	
	// Call Post Forward
	Call_SKZ_OnTimerEnd_Post(client, course, style, time, teleportsUsed, theoreticalTime);
}

bool TimerStop(int client)
{
	if (!timerRunning[client])
	{
		return false;
	}
	
	timerRunning[client] = false;
	PlayTimerStopSound(client);
	
	Call_SKZ_OnTimerStopped(client);
	
	return true;
}

void TimerStopAll()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			TimerStop(client);
		}
	}
}



// =========================  LISTENERS  ========================= //

void SetupClientTimer(int client)
{
	timerRunning[client] = false;
	hasStartedTimerThisMap[client] = false;
	hasEndedTimerThisMap[client] = false;
	currentTime[client] = 0.0;
}

void OnPlayerRunCmd_Timer(int client)
{
	if (IsPlayerAlive(client) && timerRunning[client] && !GetPaused(client))
	{
		currentTime[client] += GetTickInterval();
	}
}

void OnChangeMoveType_Timer(int client, MoveType newMoveType)
{
	if (newMoveType != MOVETYPE_WALK
		 && newMoveType != MOVETYPE_LADDER
		 && newMoveType != MOVETYPE_NONE)
	{
		if (TimerStop(client))
		{
			SKZ_PrintToChat(client, true, "%t", "Time Stopped (Noclipped)");
		}
	}
}

void OnTeleportToStart_Timer(int client)
{
	if (GetCurrentMapPrefix() == MapPrefix_KZPro)
	{
		TimerStop(client);
	}
	if (hasStartedTimerThisMap[client] && GetOption(client, Option_AutoRestart) == AutoRestart_Enabled)
	{
		TimerStart(client, currentCourse[client], true);
	}
}

void OnPlayerDeath_Timer(int client)
{
	TimerStop(client);
}

void OnOptionChanged_Timer(int client, Option option)
{
	if (option == Option_Style)
	{
		if (TimerStop(client))
		{
			SKZ_PrintToChat(client, true, "%t", "Time Stopped (Changed Style)");
		}
	}
}

void OnRoundStart_Timer()
{
	TimerStopAll();
}



// =========================  PRIVATE  ========================= //

static void PlayTimerStartSound(int client)
{
	switch (GetOption(client, Option_Style))
	{
		case Style_Standard:
		{
			EmitSoundToClient(client, STYLE_STANDARD_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_STANDARD_SOUND_START);
		}
		case Style_Legacy:
		{
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_START);
		}
		case Style_Competitive:
		{
			EmitSoundToClient(client, STYLE_COMPETITIVE_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_COMPETITIVE_SOUND_START);
		}
	}
}

static void PlayTimerEndSound(int client)
{
	switch (GetOption(client, Option_Style))
	{
		case Style_Standard:
		{
			EmitSoundToClient(client, STYLE_STANDARD_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_STANDARD_SOUND_END);
		}
		case Style_Legacy:
		{
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_END);
		}
		case Style_Competitive:
		{
			EmitSoundToClient(client, STYLE_COMPETITIVE_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_COMPETITIVE_SOUND_START);
		}
	}
}

static void PlayTimerStopSound(int client)
{
	EmitSoundToClient(client, SOUND_TIMER_STOP);
	EmitSoundToClientSpectators(client, SOUND_TIMER_STOP);
}

static void PrintEndTimeString(int client)
{
	if (currentCourse[client] == 0)
	{
		switch (GetCurrentTimeType(client))
		{
			case TimeType_Nub:
			{
				SKZ_PrintToChatAll(true, "%t", "Beat Map (Nub)", 
					client, 
					SKZ_FormatTime(currentTime[client]), 
					GetTeleportCount(client), 
					SKZ_FormatTime(currentTime[client] - GetWastedTime(client)), 
					gC_StylePhrases[GetOption(client, Option_Style)]);
			}
			case TimeType_Pro:
			{
				SKZ_PrintToChatAll(true, "%t", "Beat Map (Pro)", 
					client, 
					SKZ_FormatTime(currentTime[client]), 
					gC_StylePhrases[GetOption(client, Option_Style)]);
			}
		}
	}
	else
	{
		switch (GetCurrentTimeType(client))
		{
			case TimeType_Nub:
			{
				SKZ_PrintToChatAll(true, "%t", "Beat Bonus (Nub)", 
					client, 
					currentCourse[client], 
					SKZ_FormatTime(currentTime[client]), 
					GetTeleportCount(client), 
					SKZ_FormatTime(currentTime[client] - GetWastedTime(client)), 
					gC_StylePhrases[GetOption(client, Option_Style)]);
			}
			case TimeType_Pro:
			{
				SKZ_PrintToChatAll(true, "%t", "Beat Bonus (Pro)", 
					client, 
					currentCourse[client], 
					SKZ_FormatTime(currentTime[client]), 
					gC_StylePhrases[GetOption(client, Option_Style)]);
			}
		}
	}
} 
