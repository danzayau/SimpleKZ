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
	
	if (g_TimerText[client] == KZTimerText_Disabled)
	{
		return;
	}
	
	switch (g_TimerText[client])
	{
		case KZTimerText_Disabled:
		{
			return;
		}
		case KZTimerText_Top:
		{
			SetHudTextParams(-1.0, 0.013, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
		}
		case KZTimerText_Bottom:
		{
			SetHudTextParams(-1.0, 0.957, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
		}
	}
	
	if (IsPlayerAlive(client) && gB_TimerRunning[client])
	{
		ShowHudText(client, 0, SKZ_FormatTime(gF_CurrentTime[client]));
	}
	else
	{
		int spectatedPlayer = GetSpectatedClient(client);
		if (IsValidClient(spectatedPlayer) && gB_TimerRunning[spectatedPlayer])
		{
			ShowHudText(client, 0, SKZ_FormatTime(gF_CurrentTime[spectatedPlayer]));
		}
	}
} 