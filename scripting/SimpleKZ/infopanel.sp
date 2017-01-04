/*	infopanel.sp
	
	Centre information panel (hint text).
*/

void UpdateInfoPanel(int client) {
	MovementPlayer player = g_MovementPlayer[client];
	if (gB_UsingInfoPanel[player.id]) {
		if (IsPlayerAlive(player.id)) {
			PrintHintText(player.id, "%s", GetInfoPanelTextAlive(player));
		}
		else {
			int spectatedPlayer = GetSpectatedPlayer(player.id);
			if (IsValidClient(spectatedPlayer)) {
				PrintHintText(player.id, "%s", GetInfoPanelTextSpectating(g_MovementPlayer[spectatedPlayer]));
			}
		}
	}
}

char[] GetInfoPanelTextAlive(MovementPlayer player) {
	char infoPanelText[512];
	if (!gB_Paused[player.id]) {
		Format(infoPanelText, sizeof(infoPanelText), 
			"<font color='#948d8d'>%s %s\n%s %s", 
			GetInfoPanelTimeString(player), 
			GetInfoPanelPausedString(player), 
			GetInfoPanelSpeedString(player), 
			GetInfoPanelTakeoffString(player));
	}
	else {
		Format(infoPanelText, sizeof(infoPanelText), 
			"<font color='#948d8d'>%s %s", 
			GetInfoPanelTimeString(player), 
			GetInfoPanelPausedString(player));
	}
	return infoPanelText;
}

char[] GetInfoPanelTextSpectating(MovementPlayer player) {
	return GetInfoPanelTextAlive(player);
}

char[] GetInfoPanelTimeString(MovementPlayer player) {
	char timeString[64];
	if (gB_TimerRunning[player.id]) {
		if (GetRunType(player.id) == 0) {
			Format(timeString, sizeof(timeString), " <b>Time</b>: <font color='#6699ff'>%s</font>", TimerFormatTime(gF_CurrentTime[player.id]));
		}
		else {
			Format(timeString, sizeof(timeString), " <b>Time</b>: <font color='#ffdd99'>%s</font>", TimerFormatTime(gF_CurrentTime[player.id]));
		}
	}
	else {
		timeString = " <b>Time</b>: Stopped";
	}
	return timeString;
}

char[] GetInfoPanelPausedString(MovementPlayer player) {
	char pausedString[64];
	if (gB_Paused[player.id]) {
		pausedString = "(PAUSED)";
	}
	else {
		pausedString = "";
	}
	return pausedString;
}

char[] GetInfoPanelSpeedString(MovementPlayer player) {
	char speedString[64];
	if (player.onGround) {
		Format(speedString, sizeof(speedString), " <b>Speed</b>: %.0f u/s", RoundFloat(player.speed * 10) / 10.0);
	}
	else {
		Format(speedString, sizeof(speedString), " <b>Speed</b>: %.0f", RoundFloat(player.speed * 10) / 10.0);
	}
	return speedString;
}

char[] GetInfoPanelTakeoffString(MovementPlayer player) {
	char takeoffString[64];
	if (!player.onGround) {
		if (MT_GetHitPerf(player.id)) {
			Format(takeoffString, sizeof(takeoffString), "(<font color='#03cc00'>%.0f</font>)", RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
		else {
			Format(takeoffString, sizeof(takeoffString), "(%.0f)", RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
	}
	return takeoffString;
} 