/*    
    No Bunnyhop Checkpoint
    
    Stops players from making checkpoints on bunnyhop blocks.
*/

void NoBhopBlockCPSetup(int client)
{
	gI_JustTouchedTrigMulti[client] = 0;
}

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

bool JustTouchedBhopBlock(int client)
{
	// If just touched trigger_multiple and landed within 0.2 seconds ago
	if ((gI_JustTouchedTrigMulti[client] > 0)
		 && (GetGameTickCount() - g_MovementPlayer[client].landingTick) < (TIME_BHOP_TRIGGER_DETECTION / GetTickInterval()))
	{
		return true;
	}
	return false;
} 