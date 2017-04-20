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
	
	if (IsPlayerAlive(client))
	{
		SpeedTextShow(g_KZPlayer[client], g_KZPlayer[client]);
	}
	else {
		int spectatedClient = GetSpectatedClient(client);
		if (IsValidClient(spectatedClient))
		{
			SpeedTextShow(g_KZPlayer[client], g_KZPlayer[spectatedClient]);
		}
	}
}



/*===============================  Static Functions  ===============================*/

static void SpeedTextShow(KZPlayer player, KZPlayer targetPlayer)
{
	if (targetPlayer.paused
		 || player.speedText == KZSpeedText_Disabled
		 || player.speedText == KZSpeedText_InfoPanel)
	{
		return;
	}
	
	switch (player.speedText)
	{
		case KZSpeedText_Bottom:
		{
			if (targetPlayer.hitPerf && !targetPlayer.onGround && !targetPlayer.onLadder && !targetPlayer.noclipping)
			{
				if (IsPlayerAlive(player.id))
				{
					SetHudTextParams(-1.0, 0.75, 0.1, 3, 204, 0, 0, 1, 0.0, 0.0, 0.0);
				}
				else
				{
					SetHudTextParams(-1.0, 0.595, 0.1, 3, 204, 0, 0, 0, 0.0, 0.0, 0.0);
				}
			}
			else if (IsPlayerAlive(player.id))
			{
				SetHudTextParams(-1.0, 0.75, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
			}
			else
			{
				SetHudTextParams(-1.0, 0.595, 0.1, 255, 255, 255, 0, 0, 0.0, 0.0, 0.0);
			}
		}
	}
	
	if (targetPlayer.onGround || targetPlayer.onLadder || targetPlayer.noclipping) {
		ShowHudText(player.id, 1, "%.0f", 
			RoundFloat(targetPlayer.speed * 10) / 10.0);
	}
	else {
		ShowHudText(player.id, 1, "%.0f\n(%.0f)", 
			RoundFloat(targetPlayer.speed * 10) / 10.0, 
			RoundFloat(targetPlayer.takeoffSpeed * 10) / 10.0);
	}
} 