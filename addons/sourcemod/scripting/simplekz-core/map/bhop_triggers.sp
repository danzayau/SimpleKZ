/*
	Bunnyhop Trigger Detection
	
	Detects when players are on bunnyhop triggers and shouldn't be allowed to checkpoint.
*/

#define TIME_BHOP_TRIGGER_DETECTION 0.2 // Time after touching trigger_multiple to block checkpoints

void BhopTriggersSetupClient(int client)
{
	gI_JustTouchedTrigMulti[client] = 0;
}

// Returns if the plugin thinks the player just touched a b-hop block trigger.
bool BhopTriggersJustTouched(int client)
{
	// If just touched trigger_multiple and landed within 0.2 seconds ago
	if ((gI_JustTouchedTrigMulti[client] > 0)
		 && (GetGameTickCount() - g_KZPlayer[client].landingTick) < (TIME_BHOP_TRIGGER_DETECTION / GetTickInterval()))
	{
		return true;
	}
	return false;
}

void BhopTriggersOnTrigMultiTouch(int activator)
{
	if (IsValidClient(activator))
	{
		gI_JustTouchedTrigMulti[activator]++;
		CreateTimer(TIME_BHOP_TRIGGER_DETECTION, TrigMultiStartTouchDelayed, activator);
	}
}



/*===============================  Public Callbacks  ===============================*/

public Action TrigMultiStartTouchDelayed(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		if (gI_JustTouchedTrigMulti[client] > 0)
		{
			gI_JustTouchedTrigMulti[client]--;
		}
	}
	return Plugin_Continue;
} 