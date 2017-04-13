/*	
	Pause
	
	Pausing and resuming functionality.
*/

#define TIME_PAUSE_COOLDOWN 1.0

void TogglePause(int client)
{
	if (gB_Paused[client])
	{
		Resume(client);
	}
	else
	{
		Pause(client);
	}
}

void Pause(int client)
{
	if (gB_Paused[client])
	{
		return;
	}
	if (gB_TimerRunning[client] && gB_HasResumedInThisRun[client]
		 && gF_CurrentTime[client] - gF_LastResumeTime[client] < TIME_PAUSE_COOLDOWN)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Just Resumed)");
		return;
	}
	// Can't pause in the air if timer is running and player is moving
	if (gB_TimerRunning[client] && !g_KZPlayer[client].onGround
		 && !(g_KZPlayer[client].speed == 0 && g_KZPlayer[client].verticalVelocity == 0))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Midair)");
		return;
	}
	
	gB_Paused[client] = true;
	if (gB_TimerRunning[client])
	{
		g_KZPlayer[client].GetEyeAngles(gF_PauseAngles[client]);
	}
	FreezePlayer(client);
	
	Call_SKZ_OnPause(client);
}

void Resume(int client)
{
	if (!gB_Paused[client])
	{
		return;
	}
	
	gB_Paused[client] = false;
	if (gB_TimerRunning[client])
	{
		gB_HasResumedInThisRun[client] = true;
		gF_LastResumeTime[client] = gF_CurrentTime[client];
		g_KZPlayer[client].SetEyeAngles(gF_PauseAngles[client]);
	}
	g_KZPlayer[client].moveType = MOVETYPE_WALK;
	
	Call_SKZ_OnResume(client);
}

void PauseOnStartNoclipping(int client)
{
	gB_Paused[client] = false; // Player forcefully left paused state by noclipping
} 