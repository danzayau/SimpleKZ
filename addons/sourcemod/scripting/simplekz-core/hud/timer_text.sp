/*
	Timer Text
	
	Uses ShowHudText to show current run time somewhere on the screen.
*/

void TimerTextUpdate(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	if (IsPlayerAlive(client))
	{
		TimerTextShow(g_KZPlayer[client], g_KZPlayer[client]);
	}
	else {
		int spectatedClient = GetSpectatedClient(client);
		if (IsValidClient(spectatedClient))
		{
			TimerTextShow(g_KZPlayer[client], g_KZPlayer[spectatedClient]);
		}
	}
}



/*===============================  Static Functions  ===============================*/

static void TimerTextShow(KZPlayer player, KZPlayer targetPlayer)
{
	if (player.timerText == KZTimerText_Disabled
		 || player.timerText == KZTimerText_InfoPanel
		 || !targetPlayer.timerRunning)
	{
		return;
	}
	
	switch (player.timerText)
	{
		case KZTimerText_Top:
		{
			SetHudTextParams(-1.0, 0.013, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
		}
		case KZTimerText_Bottom:
		{
			SetHudTextParams(-1.0, 0.957, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
		}
	}
	
	ShowHudText(player.id, 0, SKZ_FormatTime(targetPlayer.currentTime, false));
} 