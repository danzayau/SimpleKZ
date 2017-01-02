/*	infopanel.sp
	
	Implementation of centre information panel (hint text).
*/

void UpdateInfoPanel(MovementPlayer player) {
	if (gB_InfoPanel[player.id]) {
		char infoPanelText[512];
		if (IsPlayerAlive(player.id)) {
			GetInfoPanelTextAlive(player, infoPanelText, sizeof(infoPanelText));
			PrintHintText(player.id, "%s", infoPanelText);
		}
		else if (IsValidClient(GetSpectatedPlayer(player.id))) {
			GetInfoPanelTextSpectating(player, infoPanelText, sizeof(infoPanelText));
			PrintHintText(player.id, "%s", infoPanelText);
		}
		
	}
}

void GetInfoPanelTextAlive(MovementPlayer player, char[] buffer, int bufferlength) {
	char speed[64];
	char takeoffSpeed[64];
	GetSpeedString(player, speed, sizeof(speed));
	GetTakeoffSpeedString(player, takeoffSpeed, sizeof(takeoffSpeed));
	
	Format(buffer, bufferlength, 
		"<font color='#948d8d'><b>Speed</b>: %s %s", 
		speed, takeoffSpeed);
}

void GetInfoPanelTextSpectating(MovementPlayer player, char[] buffer, int bufferlength) {
	GetInfoPanelTextAlive(g_MovementPlayer[GetSpectatedPlayer(player.id)], buffer, bufferlength);
}

void GetSpeedString(MovementPlayer player, char[] buffer, int bufferSize) {
	Format(buffer, bufferSize, "%.1f", RoundFloat(player.speed * 10) / 10.0);
}

void GetTakeoffSpeedString(MovementPlayer player, char[] buffer, int bufferSize) {
	if (!player.onGround) {
		if (MT_GetHitPerf(player.id)) {
			Format(buffer, bufferSize, "(<font color='#21982a'>%.1f</font>)", RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
		else {
			Format(buffer, bufferSize, "(%.1f)", RoundFloat(player.takeoffSpeed * 10) / 10.0);
		}
	}
} 