/*	infopanel.sp
	
	Centre information panel (hint text).
*/


void UpdateInfoPanel(int client) {
	if (gB_ShowingInfoPanel[client]) {
		MovementPlayer player = g_MovementPlayer[client];
		if (IsPlayerAlive(player.id)) {
			if (gB_ShowingKeys[player.id]) {
				PrintHintText(player.id, "%s", GetInfoPanelWithKeys(player));
			}
			else {
				PrintHintText(player.id, "%s", GetInfoPanel(player));
			}
		}
		else {
			int spectatedPlayer = GetSpectatedPlayer(player.id);
			if (IsValidClient(spectatedPlayer)) {
				PrintHintText(player.id, "%s", GetInfoPanelWithKeys(g_MovementPlayer[spectatedPlayer]));
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

char[] GetInfoPanelTimeString(MovementPlayer player) {
	char timeString[64];
	if (gB_TimerRunning[player.id]) {
		switch (GetCurrentRunType(player.id)) {
			case RunType_Normal: {
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#ffdd99'>%s</font>", 
					"InfoPanel_Time", player.id, 
					FormatTimeFloat(gF_CurrentTime[player.id]));
			}
			case RunType_Pro: {
				FormatEx(timeString, sizeof(timeString), 
					" <b>%T</b>: <font color='#6699ff'>%s</font>", 
					"InfoPanel_Time", player.id, 
					FormatTimeFloat(gF_CurrentTime[player.id]));
			}
		}
	}
	else {
		FormatEx(timeString, sizeof(timeString), 
			" <b>%T</b>: %T", 
			"InfoPanel_Time", player.id, 
			"InfoPanel_Stopped", player.id);
	}
	return timeString;
}

char[] GetInfoPanelPausedString(MovementPlayer player) {
	char pausedString[64];
	if (gB_Paused[player.id]) {
		FormatEx(pausedString, sizeof(pausedString), 
			"(<font color='#999999'>%T</font>)", 
			"InfoPanel_Paused", player.id);
	}
	else {
		pausedString = "";
	}
	return pausedString;
}

char[] GetInfoPanelSpeedString(MovementPlayer player) {
	char speedString[64];
	if (!gB_Paused[player.id]) {
		if (player.onGround || player.onLadder || player.noclipping) {
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font> u/s", 
				"InfoPanel_Speed", player.id, 
				RoundFloat(player.speed * 10) / 10.0);
		}
		else {
			FormatEx(speedString, sizeof(speedString), 
				" <b>%T</b>: <font color='#999999'>%.0f</font>", 
				"InfoPanel_Speed", player.id, 
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
	if (!player.onGround && !player.onLadder && !player.noclipping) {
		if (MT_GetHitPerf(player.id)) {
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
		"InfoPanel_Keys", player.id, 
		GetInfoPanelAString(player), 
		GetInfoPanelWString(player), 
		GetInfoPanelSString(player), 
		GetInfoPanelDString(player), 
		GetInfoPanelCrouchString(player), 
		GetInfoPanelJumpString(player));
	return keysString;
}

int GetInfoPanelWString(MovementPlayer player) {
	if (GetClientButtons(player.id) & IN_FORWARD) {
		return 'W';
	}
	return '_';
}

int GetInfoPanelAString(MovementPlayer player) {
	if (GetClientButtons(player.id) & IN_MOVELEFT) {
		return 'A';
	}
	return '_';
}

int GetInfoPanelSString(MovementPlayer player) {
	if (GetClientButtons(player.id) & IN_BACK) {
		return 'S';
	}
	return '_';
}

int GetInfoPanelDString(MovementPlayer player) {
	if (GetClientButtons(player.id) & IN_MOVERIGHT) {
		return 'D';
	}
	return '_';
}

int GetInfoPanelCrouchString(MovementPlayer player) {
	if (GetClientButtons(player.id) & IN_DUCK) {
		return 'C';
	}
	return '_';
}

int GetInfoPanelJumpString(MovementPlayer player) {
	if (GetClientButtons(player.id) & IN_JUMP) {
		return 'J';
	}
	return '_';
} 