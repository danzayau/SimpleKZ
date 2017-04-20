/*
	Speed Text
	
	Uses ShowHudText to show current speed somewhere on the screen.
*/

void SpeedTextUpdate(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	if (gB_Paused[client]
		 || g_SpeedText[client] == KZSpeedText_Disabled
		 || g_SpeedText[client] == KZSpeedText_InfoPanel)
	{
		return;
	}
	
	switch (g_SpeedText[client])
	{
		case KZSpeedText_Bottom:
		{
			if (IsPlayerAlive(client))
			{
				SetHudTextParams(-1.0, 0.75, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
			}
			else
			{
				SetHudTextParams(-1.0, 0.595, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
			}
		}
	}
	
	if (IsPlayerAlive(client))
	{
		if (g_KZPlayer[client].onGround || g_KZPlayer[client].onLadder || g_KZPlayer[client].noclipping) {
			ShowHudText(client, 1, "%.0f", 
				RoundFloat(g_KZPlayer[client].speed * 10) / 10.0);
		}
		else {
			ShowHudText(client, 1, "%.0f\n(%.0f)", 
				RoundFloat(g_KZPlayer[client].speed * 10) / 10.0, 
				RoundFloat(g_KZPlayer[client].takeoffSpeed * 10) / 10.0);
		}
	}
	else
	{
		int spectatedPlayer = GetSpectatedClient(client);
		if (IsValidClient(spectatedPlayer))
		{
			if (g_KZPlayer[spectatedPlayer].onGround) {
				ShowHudText(client, 1, "%.0f", 
					RoundFloat(g_KZPlayer[spectatedPlayer].speed * 10) / 10.0);
			}
			else {
				ShowHudText(client, 1, "%.0f\n(%.0f)", 
					RoundFloat(g_KZPlayer[spectatedPlayer].speed * 10) / 10.0, 
					RoundFloat(g_KZPlayer[spectatedPlayer].takeoffSpeed * 10) / 10.0);
			}
		}
	}
} 