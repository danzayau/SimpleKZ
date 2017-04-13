/*	
	Wasted Time
	
	Keep track of time wasted when teleporting back to checkpoints.
*/

// Called in misc/teleports.sp
void AddWastedTimeTeleportToStart(int client)
{
	float addedWastedTime = 0.0;
	addedWastedTime = gF_CurrentTime[client] - gF_WastedTime[client];
	gF_WastedTime[client] += addedWastedTime;
	gF_LastTeleportToStartWastedTime[client] = addedWastedTime;
	gF_LastTeleportToStartTime[client] = gF_CurrentTime[client];
}

// Called in misc/teleports.sp
void AddWastedTimeTeleportToCheckpoint(int client)
{
	float addedWastedTime = 0.0;
	if (TeleportToStartWasLatestTeleport(client))
	{
		addedWastedTime -= gF_LastTeleportToStartWastedTime[client];
	}
	if (UndoWasLatestTeleport(client))
	{
		addedWastedTime -= gF_LastUndoWastedTime[client];
	}
	addedWastedTime += gF_CurrentTime[client] - FloatMax(gF_LastCheckpointTime[client], gF_LastGoCheckTime[client]);
	gF_WastedTime[client] += addedWastedTime;
	gF_LastGoCheckWastedTime[client] = addedWastedTime;
	gF_LastGoCheckTime[client] = gF_CurrentTime[client];
}

// Called in misc/teleports.sp
void AddWastedTimeUndoTeleport(int client)
{
	float addedWastedTime = 0.0;
	if (TeleportToStartWasLatestTeleport(client))
	{
		addedWastedTime -= gF_LastTeleportToStartWastedTime[client];
		addedWastedTime += gF_CurrentTime[client] - gF_LastTeleportToStartTime[client];
	}
	else if (UndoWasLatestTeleport(client))
	{
		addedWastedTime -= gF_LastUndoWastedTime[client];
		addedWastedTime += gF_CurrentTime[client] - gF_LastUndoTime[client];
	}
	else
	{
		addedWastedTime -= gF_LastGoCheckWastedTime[client];
		addedWastedTime += gF_CurrentTime[client] - gF_LastGoCheckTime[client];
	}
	gF_WastedTime[client] += addedWastedTime;
	gF_LastUndoWastedTime[client] = addedWastedTime;
	gF_LastUndoTime[client] = gF_CurrentTime[client];
}



/*===============================  Static Functions  ===============================*/

static bool UndoWasLatestTeleport(int client)
{
	return gF_LastUndoTime[client] > gF_LastGoCheckTime[client]
	 && gF_LastUndoTime[client] > gF_LastTeleportToStartTime[client];
}

static bool TeleportToStartWasLatestTeleport(int client)
{
	return gF_LastTeleportToStartTime[client] > gF_LastGoCheckTime[client]
	 && gF_LastTeleportToStartTime[client] > gF_LastUndoTime[client];
} 