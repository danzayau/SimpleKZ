/*	
	Pause
	
	Pausing and resuming functionality.
*/



#define PAUSE_COOLDOWN 1.0

static bool paused[MAXPLAYERS + 1];
static float lastPauseTime[MAXPLAYERS + 1];
static bool hasPausedInThisRun[MAXPLAYERS + 1];
static float lastResumeTime[MAXPLAYERS + 1];
static bool hasResumedInThisRun[MAXPLAYERS + 1];



// =========================  PUBLIC  ========================= //

bool GetPaused(int client)
{
	return paused[client];
}

void Pause(int client)
{
	if (paused[client])
	{
		return;
	}
	if (GetTimerRunning(client) && hasResumedInThisRun[client]
		 && GetEngineTime() - lastResumeTime[client] < PAUSE_COOLDOWN)
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Pause (Just Resumed)");
		PlayErrorSound(client);
		return;
	}
	if (GetTimerRunning(client)
		 && !Movement_GetOnGround(client)
		 && !(Movement_GetSpeed(client) == 0 && Movement_GetVerticalVelocity(client) == 0))
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Pause (Midair)");
		PlayErrorSound(client);
		return;
	}
	
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnPause(client, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// Pause
	paused[client] = true;
	Movement_SetVelocity(client, view_as<float>( { 0.0, 0.0, 0.0 } ));
	Movement_SetMoveType(client, MOVETYPE_NONE);
	if (GetTimerRunning(client))
	{
		hasPausedInThisRun[client] = true;
		lastPauseTime[client] = GetEngineTime();
	}
	
	// Call Post Forward
	Call_SKZ_OnPause_Post(client);
}

void Resume(int client)
{
	if (!paused[client])
	{
		return;
	}
	if (GetTimerRunning(client) && hasPausedInThisRun[client]
		 && GetEngineTime() - lastPauseTime[client] < PAUSE_COOLDOWN)
	{
		SKZ_PrintToChat(client, true, "%t", "Can't Resume (Just Paused)");
		PlayErrorSound(client);
		return;
	}
	
	// Call Pre Forward
	Action result;
	int error = Call_SKZ_OnResume(client, result);
	if (error != SP_ERROR_NONE || result != Plugin_Continue)
	{
		return;
	}
	
	// Resume
	Movement_SetMoveType(client, MOVETYPE_WALK);
	paused[client] = false;
	if (GetTimerRunning(client))
	{
		hasResumedInThisRun[client] = true;
		lastResumeTime[client] = GetEngineTime();
	}
	
	// Call Post Forward
	Call_SKZ_OnResume_Post(client);
}

void TogglePause(int client)
{
	if (paused[client])
	{
		Resume(client);
	}
	else
	{
		Pause(client);
	}
}



// =========================  LISTENERS  ========================= //

void OnTimerStart_Pause(int client)
{
	paused[client] = false;
	lastResumeTime[client] = 0.0;
	hasPausedInThisRun[client] = false;
	hasResumedInThisRun[client] = false;
}

void OnChangeMoveType_Pause(int client, MoveType newMoveType)
{
	// Check if player has escaped MOVETYPE_NONE
	if (!paused[client] || newMoveType == MOVETYPE_NONE)
	{
		return;
	}
	
	// Player has escaped MOVETYPE_NONE, so resume
	paused[client] = false;
	if (GetTimerRunning(client))
	{
		hasResumedInThisRun[client] = true;
		lastResumeTime[client] = GetEngineTime();
	}
	
	// Call Post Forward
	Call_SKZ_OnResume_Post(client);
}

void OnPlayerDeath_Pause(int client)
{
	paused[client] = false;
} 