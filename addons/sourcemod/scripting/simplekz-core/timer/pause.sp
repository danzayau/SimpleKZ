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
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		JoinTeam(client, CS_TEAM_CT);
	}
	else if (gB_TimerRunning[client] && gB_HasResumedInThisRun[client] && gF_CurrentTime[client] - gF_LastResumeTime[client] < TIME_PAUSE_COOLDOWN)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Just Resumed)");
	}
	// Can't pause in the air if timer is running and player is moving
	else if (gB_TimerRunning[client] && !g_MovementPlayer[client].onGround
		 && !(g_MovementPlayer[client].speed == 0 && g_MovementPlayer[client].verticalVelocity == 0))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Midair)");
	}
	else
	{
		gB_Paused[client] = true;
		if (gB_TimerRunning[client])
		{
			g_MovementPlayer[client].GetEyeAngles(gF_PauseAngles[client]);
		}
		FreezePlayer(client);
		Call_SKZ_OnPlayerPause(client);
	}
	CloseTPMenu(client);
}

void Resume(int client)
{
	if (!gB_Paused[client])
	{
		return;
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		JoinTeam(client, CS_TEAM_CT);
	}
	else
	{
		gB_Paused[client] = false;
		if (gB_TimerRunning[client])
		{
			gB_HasResumedInThisRun[client] = true;
			gF_LastResumeTime[client] = gF_CurrentTime[client];
			g_MovementPlayer[client].SetEyeAngles(gF_PauseAngles[client]);
		}
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
		Call_SKZ_OnPlayerResume(client);
	}
	CloseTPMenu(client);
}

void PauseOnStartNoclipping(int client)
{
	gB_Paused[client] = false; // Player forcefully left paused state by noclipping
	if (TimerForceStop(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped (Noclipped)");
	}
} 