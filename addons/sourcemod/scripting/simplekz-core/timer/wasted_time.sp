/*	
	Wasted Time
	
	Keep track of time wasted when teleporting back to checkpoints.
*/



static float wastedTime[MAXPLAYERS + 1];
static float lastCheckpointTime[MAXPLAYERS + 1];
static float lastGoCheckTime[MAXPLAYERS + 1];
static float lastGoCheckWastedTime[MAXPLAYERS + 1];
static float lastUndoTime[MAXPLAYERS + 1];
static float lastUndoWastedTime[MAXPLAYERS + 1];
static float lastTeleportToStartTime[MAXPLAYERS + 1];
static float lastTeleportToStartWastedTime[MAXPLAYERS + 1];



// =========================  PUBLIC  ========================= //

float GetWastedTime(int client)
{
	return wastedTime[client];
}



// =========================  LISTENERS  ========================= //

void OnTimerStart_WastedTime(int client)
{
	wastedTime[client] = 0.0;
	lastCheckpointTime[client] = 0.0;
	lastGoCheckTime[client] = 0.0;
	lastGoCheckWastedTime[client] = 0.0;
	lastUndoTime[client] = 0.0;
	lastUndoWastedTime[client] = 0.0;
	lastTeleportToStartTime[client] = 0.0;
	lastTeleportToStartWastedTime[client] = 0.0;
}

void OnMakeCheckpoint_WastedTime(int client)
{
	lastCheckpointTime[client] = GetCurrentTime(client);
}

void OnTeleportToStart_WastedTime(int client)
{
	float addedWastedTime = 0.0;
	addedWastedTime = GetCurrentTime(client) - wastedTime[client];
	wastedTime[client] += addedWastedTime;
	lastTeleportToStartWastedTime[client] = addedWastedTime;
	lastTeleportToStartTime[client] = GetCurrentTime(client);
}

void OnTeleportToCheckpoint_WastedTime(int client)
{
	float addedWastedTime = 0.0;
	if (TeleportToStartWasLastTeleport(client))
	{
		addedWastedTime -= lastTeleportToStartWastedTime[client];
	}
	if (UndoWasLastTeleport(client))
	{
		addedWastedTime -= lastUndoWastedTime[client];
	}
	addedWastedTime += GetCurrentTime(client) - FloatMax(lastCheckpointTime[client], lastGoCheckTime[client]);
	wastedTime[client] += addedWastedTime;
	lastGoCheckWastedTime[client] = addedWastedTime;
	lastGoCheckTime[client] = GetCurrentTime(client);
}

void OnUndoTeleport_WastedTime(int client)
{
	float addedWastedTime = 0.0;
	if (TeleportToStartWasLastTeleport(client))
	{
		addedWastedTime -= lastTeleportToStartWastedTime[client];
		addedWastedTime += GetCurrentTime(client) - lastTeleportToStartTime[client];
	}
	else if (UndoWasLastTeleport(client))
	{
		addedWastedTime -= lastUndoWastedTime[client];
		addedWastedTime += GetCurrentTime(client) - lastUndoTime[client];
	}
	else
	{
		addedWastedTime -= lastGoCheckWastedTime[client];
		addedWastedTime += GetCurrentTime(client) - lastGoCheckTime[client];
	}
	wastedTime[client] += addedWastedTime;
	lastUndoWastedTime[client] = addedWastedTime;
	lastUndoTime[client] = GetCurrentTime(client);
}



// =========================  PRIVATE  ========================= //

static bool UndoWasLastTeleport(int client)
{
	return lastUndoTime[client] > lastGoCheckTime[client]
	 && lastUndoTime[client] > lastTeleportToStartTime[client];
}

static bool TeleportToStartWasLastTeleport(int client)
{
	return lastTeleportToStartTime[client] > lastGoCheckTime[client]
	 && lastTeleportToStartTime[client] > lastUndoTime[client];
} 