/*
	No Bunnyhop Checkpoint
	
	Detects when players are on bunnyhop blocks.
*/

#define TIME_BHOP_TRIGGER_DETECTION 0.2 // Time after touching trigger_multiple to block checkpoints

void NoBhopCPSetupClient(int client)
{
	gI_JustTouchedTrigMulti[client] = 0;
}

void NoBhopCPCreateHooks()
{
	HookEntityOutput("trigger_multiple", "OnStartTouch", OnTrigMultiStartTouch);
}

// Returns if the plugin thinks the player just touched a b-hop block trigger.
bool JustTouchedBhopBlock(int client)
{
	// If just touched trigger_multiple and landed within 0.2 seconds ago
	if ((gI_JustTouchedTrigMulti[client] > 0)
		 && (GetGameTickCount() - g_KZPlayer[client].landingTick) < (TIME_BHOP_TRIGGER_DETECTION / GetTickInterval()))
	{
		return true;
	}
	return false;
}



/*===============================  Public Callbacks  ===============================*/

public void OnTrigMultiStartTouch(const char[] name, int caller, int activator, float delay)
{
	if (IsValidClient(activator))
	{
		gI_JustTouchedTrigMulti[activator]++;
		CreateTimer(TIME_BHOP_TRIGGER_DETECTION, TrigMultiStartTouchDelayed, activator);
	}
}

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