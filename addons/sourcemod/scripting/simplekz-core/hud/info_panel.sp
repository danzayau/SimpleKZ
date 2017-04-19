/*
	Information Panel
	
	Centre information panel (hint text).
*/

// Generates and prints a new info panel for the player, if it's enabled.
void InfoPanelUpdate(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	if (g_ShowingInfoPanel[client] == KZShowingInfoPanel_Disabled)
	{
		return;
	}
	
	if ((g_ShowingKeys[client] == KZShowingKeys_Disabled || IsPlayerAlive(client) && g_ShowingKeys[client] == KZShowingKeys_Spectating)
		 && g_TimerText[client] != KZTimerText_InfoPanel
		 && g_SpeedText[client] != KZSpeedText_InfoPanel)
	{
		return;
	}
	
	if (IsPlayerAlive(client))
	{
		PrintHintText(client, "%s", GetInfoPanel(g_KZPlayer[client], g_KZPlayer[client]));
	}
	else
	{
		int spectatedClient = GetSpectatedClient(client);
		if (IsValidClient(spectatedClient))
		{
			PrintHintText(client, "%s", GetInfoPanel(g_KZPlayer[client], g_KZPlayer[spectatedClient]));
		}
	}
}



/*===============================  Static Functions  ===============================*/

static char[] GetInfoPanel(KZPlayer player, KZPlayer targetPlayer)
{
	char infoPanelText[320];
	FormatEx(infoPanelText, sizeof(infoPanelText), 
		"<font color='#4d4d4d'>%s %s\n%s\n%s", 
		GetTimeString(player, targetPlayer), 
		GetPausedString(player, targetPlayer), 
		GetSpeedString(player, targetPlayer), 
		GetKeysString(player, targetPlayer));
	return infoPanelText;
}

static char[] GetTimeString(KZPlayer player, KZPlayer targetPlayer)
{
	char timeString[64];
	if (player.timerText != KZTimerText_InfoPanel) {
		timeString = "";
	}
	else if (targetPlayer.timerRunning)
	{
		switch (GetCurrentTimeType(targetPlayer.id))
		{
			case KZTimeType_Normal:
			{
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#ffdd99'>%s</font>", 
					"Info Panel Text - Time", player.id, 
					SKZ_FormatTime(gF_CurrentTime[targetPlayer.id]));
			}
			case KZTimeType_Pro:
			{
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#6699ff'>%s</font>", 
					"Info Panel Text - Time", player.id, 
					SKZ_FormatTime(gF_CurrentTime[targetPlayer.id]));
			}
		}
	}
	else
	{
		FormatEx(timeString, sizeof(timeString), 
			" <b>%T</b>: %T", 
			"Info Panel Text - Time", player.id, 
			"Info Panel Text - Stopped", player.id);
	}
	return timeString;
}

static char[] GetPausedString(KZPlayer player, KZPlayer targetPlayer)
{
	char pausedString[64];
	if (gB_Paused[targetPlayer.id])
	{
		FormatEx(pausedString, sizeof(pausedString), 
			"(<font color='#999999'>%T</font>)", 
			"Info Panel Text - PAUSED", player.id);
	}
	else
	{
		pausedString = "";
	}
	return pausedString;
}

static char[] GetSpeedString(KZPlayer player, KZPlayer targetPlayer)
{
	char speedString[128];
	if (player.speedText != KZSpeedText_InfoPanel || player.paused) {
		speedString = "";
	}
	else
	{
		if (targetPlayer.onGround || targetPlayer.onLadder || targetPlayer.noclipping)
		{
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font> u/s", 
				"Info Panel Text - Speed", player.id, 
				RoundFloat(targetPlayer.speed * 10) / 10.0);
		}
		else
		{
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font> %s", 
				"Info Panel Text - Speed", player.id, 
				RoundFloat(targetPlayer.speed * 10) / 10.0, 
				GetTakeoffString(targetPlayer));
		}
	}
	return speedString;
}

static char[] GetTakeoffString(KZPlayer targetPlayer)
{
	char takeoffString[64];
	if (targetPlayer.hitPerf)
	{
		FormatEx(takeoffString, sizeof(takeoffString), 
			"(<font color='#03cc00'>%.0f</font>)", 
			RoundFloat(targetPlayer.takeoffSpeed * 10) / 10.0);
	}
	else
	{
		FormatEx(takeoffString, sizeof(takeoffString), 
			"(<font color='#999999'>%.0f</font>)", 
			RoundFloat(targetPlayer.takeoffSpeed * 10) / 10.0);
	}
	return takeoffString;
}

static char[] GetKeysString(KZPlayer player, KZPlayer targetPlayer)
{
	char keysString[64];
	if (player.showingKeys == KZShowingKeys_Disabled)
	{
		keysString = "";
	}
	else if (player.showingKeys == KZShowingKeys_Spectating && IsPlayerAlive(player.id))
	{
		keysString = "";
	}
	else
	{
		FormatEx(keysString, sizeof(keysString), 
			" <b>%T</b>: <font color='#999999'>%c %c %c %c   %c %c</font>", 
			"Info Panel Text - Keys", player.id, 
			GetAString(targetPlayer), 
			GetWString(targetPlayer), 
			GetSString(targetPlayer), 
			GetDString(targetPlayer), 
			GetCrouchString(targetPlayer), 
			GetJumpString(targetPlayer));
	}
	return keysString;
}

static int GetWString(KZPlayer targetPlayer)
{
	if (targetPlayer.buttons & IN_FORWARD)
	{
		return 'W';
	}
	return '_';
}

static int GetAString(KZPlayer targetPlayer)
{
	if (targetPlayer.buttons & IN_MOVELEFT)
	{
		return 'A';
	}
	return '_';
}

static int GetSString(KZPlayer targetPlayer)
{
	if (targetPlayer.buttons & IN_BACK)
	{
		return 'S';
	}
	return '_';
}

static int GetDString(KZPlayer targetPlayer)
{
	if (targetPlayer.buttons & IN_MOVERIGHT)
	{
		return 'D';
	}
	return '_';
}

static int GetCrouchString(KZPlayer targetPlayer)
{
	if (targetPlayer.buttons & IN_DUCK)
	{
		return 'C';
	}
	return '_';
}

static int GetJumpString(KZPlayer targetPlayer)
{
	if (targetPlayer.buttons & IN_JUMP)
	{
		return 'J';
	}
	return '_';
} 