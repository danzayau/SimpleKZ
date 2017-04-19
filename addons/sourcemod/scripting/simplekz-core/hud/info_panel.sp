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
	
	if (g_ShowingInfoPanel[client] != KZShowingInfoPanel_Enabled
		)
	{
		return;
	}
	
	if (g_ShowingKeys[client] == KZShowingKeys_Disabled
		 && g_TimerText[client] != KZTimerText_InfoPanel
		 && g_SpeedText[client] != KZSpeedText_InfoPanel)
	{
		return;
	}
	
	KZPlayer player = g_KZPlayer[client];
	if (IsPlayerAlive(player.id))
	{
		PrintHintText(player.id, "%s", GetInfoPanel(player));
	}
	else
	{
		int spectatedPlayer = GetSpectatedClient(player.id);
		if (IsValidClient(spectatedPlayer))
		{
			PrintHintText(player.id, "%s", GetInfoPanelSpectating(g_KZPlayer[spectatedPlayer]));
		}
	}
}



/*===============================  Static Functions  ===============================*/

static char[] GetInfoPanel(KZPlayer player)
{
	char infoPanelText[320];
	FormatEx(infoPanelText, sizeof(infoPanelText), 
		"<font color='#4d4d4d'>%s %s\n%s\n%s", 
		GetTimeString(player), 
		GetPausedString(player), 
		GetSpeedString(player), 
		GetKeysString(player));
	return infoPanelText;
}

static char[] GetInfoPanelSpectating(KZPlayer player)
{
	char infoPanelText[368];
	FormatEx(infoPanelText, sizeof(infoPanelText), 
		"<font color='#4d4d4d'>%s %s %s\n%s %s\n%s", 
		GetTimeString(player), 
		GetPausedString(player), 
		GetStyleString(player), 
		GetSpeedString(player), 
		GetTakeoffString(player), 
		GetKeysString(player));
	return infoPanelText;
}

static char[] GetTimeString(KZPlayer player)
{
	char timeString[64];
	if (player.timerText != KZTimerText_InfoPanel) {
		timeString = "";
	}
	else if (gB_TimerRunning[player.id])
	{
		switch (GetCurrentTimeType(player.id))
		{
			case KZTimeType_Normal:
			{
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#ffdd99'>%s</font>", 
					"Info Panel Text - Time", player.id, 
					SKZ_FormatTime(gF_CurrentTime[player.id]));
			}
			case KZTimeType_Pro:
			{
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#6699ff'>%s</font>", 
					"Info Panel Text - Time", player.id, 
					SKZ_FormatTime(gF_CurrentTime[player.id]));
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

static char[] GetPausedString(KZPlayer player)
{
	char pausedString[64];
	if (gB_Paused[player.id])
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

static char[] GetStyleString(KZPlayer player)
{
	char styleString[48];
	FormatEx(styleString, sizeof(styleString), 
		"[<font color='#B980EF'>%T</font>]", 
		gC_StylePhrases[g_Style[player.id]], player.id);
	return styleString;
}

static char[] GetSpeedString(KZPlayer player)
{
	char speedString[128];
	if (player.speedText != KZSpeedText_InfoPanel || player.paused) {
		speedString = "";
	}
	else
	{
		if (player.onGround || player.onLadder || player.noclipping)
		{
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font> u/s", 
				"Info Panel Text - Speed", player.id, 
				RoundFloat(player.speed * 10) / 10.0);
		}
		else
		{
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font> %s", 
				"Info Panel Text - Speed", player.id, 
				RoundFloat(player.speed * 10) / 10.0, 
				GetTakeoffString(player));
		}
	}
	return speedString;
}

static char[] GetTakeoffString(KZPlayer player)
{
	char takeoffString[64];
	if (player.hitPerf)
	{
		FormatEx(takeoffString, sizeof(takeoffString), 
			"(<font color='#03cc00'>%.0f</font>)", 
			RoundFloat(player.takeoffSpeed * 10) / 10.0);
	}
	else
	{
		FormatEx(takeoffString, sizeof(takeoffString), 
			"(<font color='#999999'>%.0f</font>)", 
			RoundFloat(player.takeoffSpeed * 10) / 10.0);
	}
	return takeoffString;
}

static char[] GetKeysString(KZPlayer player)
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
			GetAString(player), 
			GetWString(player), 
			GetSString(player), 
			GetDString(player), 
			GetCrouchString(player), 
			GetJumpString(player));
	}
	return keysString;
}

static int GetWString(KZPlayer player)
{
	if (player.buttons & IN_FORWARD)
	{
		return 'W';
	}
	return '_';
}

static int GetAString(KZPlayer player)
{
	if (player.buttons & IN_MOVELEFT)
	{
		return 'A';
	}
	return '_';
}

static int GetSString(KZPlayer player)
{
	if (player.buttons & IN_BACK)
	{
		return 'S';
	}
	return '_';
}

static int GetDString(KZPlayer player)
{
	if (player.buttons & IN_MOVERIGHT)
	{
		return 'D';
	}
	return '_';
}

static int GetCrouchString(KZPlayer player)
{
	if (player.buttons & IN_DUCK)
	{
		return 'C';
	}
	return '_';
}

static int GetJumpString(KZPlayer player)
{
	if (player.buttons & IN_JUMP)
	{
		return 'J';
	}
	return '_';
} 