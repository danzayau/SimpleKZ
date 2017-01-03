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
	Format(infoPanelText, sizeof(infoPanelText), 
		"<font color='#948d8d'><b>Time</b>: %s\n<b>Speed</b>: %s %s", 
		GetInfoPanelTimeString(player), GetInfoPanelSpeedString(player), GetInfoPanelTakeoffString(player));
	return infoPanelText;
}

char[] GetInfoPanelTextSpectating(MovementPlayer player) {
	return GetInfoPanelTextAlive(player);
}

char[] GetInfoPanelTimeString(MovementPlayer player) {
	char timeString[256];
	if (gB_TimerRunning[player.id]) {
		if (GetRunType(player.id) == 0) {
			Format(timeString, sizeof(timeString), "<font color='#6699ff'>%s</font>", TimerFormatTime(gF_CurrentTime[player.id]));
		}
		else {
			Format(timeString, sizeof(timeString), "<font color='#ffdd99'>%s</font>", TimerFormatTime(gF_CurrentTime[player.id]));
		}
	}
	else {
		timeString = "Stopped";
	}
	return timeString;
}

char[] GetInfoPanelSpeedString(MovementPlayer player) {
	char speedString[64];
	Format(speedString, sizeof(speedString), "%.1f", RoundFloat(player.speed * 10) / 10.0);
	return speedString;
}

char[] GetInfoPanelTakeoffString(MovementPlayer player) {
	char takeoffString[64];
	if (!player.onGround) {
		if (MT_GetHitPerf(player.id)) {
			Format(takeoffString, sizeof(takeoffString), "(<font color='#21982a'>%.1f</font>)", RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
		else {
			Format(takeoffString, sizeof(takeoffString), "(%.1f)", RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
	}
	return takeoffString;
} 