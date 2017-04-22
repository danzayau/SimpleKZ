/*
	Force Stop
	
	Invalidates (stops) the player's time when 'illegal' things happen.
*/

#define SOUND_TIMER_FORCE_STOP "buttons/button18.wav"

void TimerForceStopOnRoundStart()
{
	TimerForceStopAll();
}

void TimerForceStopOnStartNoclipping(int client)
{
	if (TimerForceStop(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped (Noclipped)");
	}
}

void TimerForceStopOnPlayerDeath(int client)
{
	TimerForceStop(client);
}

void TimerForceStopOnChangeStyle(int client) // Called from options.sp (SetOption)
{
	if (TimerForceStop(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped (Changed Style)");
	}
}

void TimerForceStopOnTeleportToStart(int client)
{
	if (gB_CurrentMapIsKZPro)
	{
		TimerForceStop(client);
	}
}

bool TimerForceStopCommand(int client) // sm_stop command
{
	return TimerForceStop(client);
}

bool TimerForceStopNative(int client) // Called from api.sp
{
	return TimerForceStop(client);
}

void TimerForceStopAllNative() // Called from api.sp
{
	TimerForceStopAll();
}



/*===============================  Static Functions  ===============================*/

// Invalidates a player's time and returns true if their timer is running, else returns false.
static bool TimerForceStop(int client)
{
	if (gB_TimerRunning[client])
	{
		TimerForceStopPlaySound(client);
		gB_TimerRunning[client] = false;
		Call_SKZ_OnTimerForceStop(client);
		TPMenuUpdate(client);
		return true;
	}
	return false;
}

// Invalidates all players' times.
static void TimerForceStopAll()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			TimerForceStop(client);
		}
	}
}

static void TimerForceStopPlaySound(int client)
{
	EmitSoundToClient(client, SOUND_TIMER_FORCE_STOP);
	EmitSoundToClientSpectators(client, SOUND_TIMER_FORCE_STOP);
} 