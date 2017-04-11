/*	infopanel.sp
	
	Centre information panel (hint text).
*/


void UpdateInfoPanel(int client) {
	if (g_ShowingInfoPanel[client] == KZShowingInfoPanel_Enabled) {
		MovementPlayer player = g_MovementPlayer[client];
		if (IsPlayerAlive(player.id)) {
			if (g_ShowingKeys[player.id] == KZShowingKeys_Enabled) {
				PrintHintText(player.id, "%s", GetInfoPanelWithKeys(player));
			}
			else {
				PrintHintText(player.id, "%s", GetInfoPanel(player));
			}
		}
		else {
			int spectatedPlayer = GetSpectatedClient(player.id);
			if (IsValidClient(spectatedPlayer)) {
				PrintHintText(player.id, "%s", GetInfoPanelSpectating(g_MovementPlayer[spectatedPlayer]));
			}
		}
	}
}

char[] GetInfoPanel(MovementPlayer player) {
	char infoPanelText[256];
	FormatEx(infoPanelText, sizeof(infoPanelText), 
		"<font color='#4d4d4d'>%s %s\n%s %s", 
		GetInfoPanelTimeString(player), 
		GetInfoPanelPausedString(player), 
		GetInfoPanelSpeedString(player), 
		GetInfoPanelTakeoffString(player));
	return infoPanelText;
}

char[] GetInfoPanelWithKeys(MovementPlayer player) {
	char infoPanelText[320];
	FormatEx(infoPanelText, sizeof(infoPanelText), 
		"<font color='#4d4d4d'>%s %s\n%s %s\n%s", 
		GetInfoPanelTimeString(player), 
		GetInfoPanelPausedString(player), 
		GetInfoPanelSpeedString(player), 
		GetInfoPanelTakeoffString(player), 
		GetInfoPanelKeysString(player));
	return infoPanelText;
}

char[] GetInfoPanelSpectating(MovementPlayer player) {
	char infoPanelText[368];
	FormatEx(infoPanelText, sizeof(infoPanelText), 
		"<font color='#4d4d4d'>%s %s %s\n%s %s\n%s", 
		GetInfoPanelTimeString(player), 
		GetInfoPanelPausedString(player), 
		GetInfoPanelStyleString(player), 
		GetInfoPanelSpeedString(player), 
		GetInfoPanelTakeoffString(player), 
		GetInfoPanelKeysString(player));
	return infoPanelText;
}

char[] GetInfoPanelTimeString(MovementPlayer player) {
	char timeString[64];
	if (gB_TimerRunning[player.id]) {
		switch (GetCurrentTimeType(player.id)) {
			case KZTimeType_Normal: {
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#ffdd99'>%s</font>", 
					"Info Panel Text - Time", player.id, 
					SimpleKZ_FormatTime(gF_CurrentTime[player.id]));
			}
			case KZTimeType_Pro: {
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#6699ff'>%s</font>", 
					"Info Panel Text - Time", player.id, 
					SimpleKZ_FormatTime(gF_CurrentTime[player.id]));
			}
		}
	}
	else {
		FormatEx(timeString, sizeof(timeString), 
			" <b>%T</b>: %T", 
			"Info Panel Text - Time", player.id, 
			"Info Panel Text - Stopped", player.id);
	}
	return timeString;
}

char[] GetInfoPanelPausedString(MovementPlayer player) {
	char pausedString[64];
	if (gB_Paused[player.id]) {
		FormatEx(pausedString, sizeof(pausedString), 
			"(<font color='#999999'>%T</font>)", 
			"Info Panel Text - PAUSED", player.id);
	}
	else {
		pausedString = "";
	}
	return pausedString;
}

char[] GetInfoPanelStyleString(MovementPlayer player) {
	char styleString[48];
	FormatEx(styleString, sizeof(styleString), 
		"[<font color='#B980EF'>%T</font>]", 
		gC_StylePhrases[g_Style[player.id]], player.id);
	return styleString;
}

char[] GetInfoPanelSpeedString(MovementPlayer player) {
	char speedString[64];
	if (!gB_Paused[player.id]) {
		if (player.onGround || player.onLadder || player.noclipping) {
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font> u/s", 
				"Info Panel Text - Speed", player.id, 
				RoundFloat(player.speed * 10) / 10.0);
		}
		else {
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font>", 
				"Info Panel Text - Speed", player.id, 
				RoundFloat(player.speed * 10) / 10.0);
		}
	}
	else {
		speedString = "";
	}
	return speedString;
}

char[] GetInfoPanelTakeoffString(MovementPlayer player) {
	char takeoffString[64];
	if (!gB_Paused[player.id] && !player.onGround && !player.onLadder && !player.noclipping) {
		if (gB_HitPerf[player.id]) {
			FormatEx(takeoffString, sizeof(takeoffString), 
				"(<font color='#03cc00'>%.0f</font>)", 
				RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
		else {
			FormatEx(takeoffString, sizeof(takeoffString), 
				"(<font color='#999999'>%.0f</font>)", 
				RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
	}
	else {
		takeoffString = "";
	}
	return takeoffString;
}

char[] GetInfoPanelKeysString(MovementPlayer player) {
	char keysString[64];
	FormatEx(keysString, sizeof(keysString), 
		" <b>%T</b>: <font color='#999999'>%c %c %c %c   %c %c</font>", 
		"Info Panel Text - Keys", player.id, 
		GetInfoPanelAString(player), 
		GetInfoPanelWString(player), 
		GetInfoPanelSString(player), 
		GetInfoPanelDString(player), 
		GetInfoPanelCrouchString(player), 
		GetInfoPanelJumpString(player));
	return keysString;
}

int GetInfoPanelWString(MovementPlayer player) {
	if (player.buttons & IN_FORWARD) {
		return 'W';
	}
	return '_';
}

int GetInfoPanelAString(MovementPlayer player) {
	if (player.buttons & IN_MOVELEFT) {
		return 'A';
	}
	return '_';
}

int GetInfoPanelSString(MovementPlayer player) {
	if (player.buttons & IN_BACK) {
		return 'S';
	}
	return '_';
}

int GetInfoPanelDString(MovementPlayer player) {
	if (player.buttons & IN_MOVERIGHT) {
		return 'D';
	}
	return '_';
}

int GetInfoPanelCrouchString(MovementPlayer player) {
	if (player.buttons & IN_DUCK) {
		return 'C';
	}
	return '_';
}

int GetInfoPanelJumpString(MovementPlayer player) {
	if (player.buttons & IN_JUMP) {
		return 'J';
	}
	return '_';
} 