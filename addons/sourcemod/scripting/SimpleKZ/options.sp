/*	options.sp
	
	Player options.
*/


void SetDefaultOptions(int client) {
	g_Style[client] = view_as<MovementStyle>(GetConVarInt(gCV_DefaultStyle));
	gB_ShowingTeleportMenu[client] = true;
	gB_ShowingInfoPanel[client] = true;
	gB_ShowingKeys[client] = false;
	gB_ShowingPlayers[client] = true;
	gB_ShowingWeapon[client] = true;
	gB_AutoRestart[client] = false;
	gB_SlayOnEnd[client] = false;
	gI_Pistol[client] = 0;
	gB_CheckpointMessages[client] = false;
	gB_CheckpointSounds[client] = false;
	gB_TeleportSounds[client] = false;
}

bool ToggleOptionBool(int client, bool option, const char[] disablePhrase, const char[] enablePhrase) {
	if (option) {
		CPrintToChat(client, "%t %t", "KZ Prefix", disablePhrase);
		return false;
	}
	CPrintToChat(client, "%t %t", "KZ Prefix", enablePhrase);
	return true;
}

void ToggleTeleportMenu(int client) {
	gB_ShowingTeleportMenu[client] = ToggleOptionBool(client, gB_ShowingTeleportMenu[client], "Option - Teleport Menu - Disable", "Option - Teleport Menu - Enable");
	CloseTeleportMenu(client);
}

void ToggleShowPlayers(int client) {
	gB_ShowingPlayers[client] = ToggleOptionBool(client, gB_ShowingPlayers[client], "Option - Show Players - Disable", "Option - Show Players - Enable");
}

void ToggleInfoPanel(int client) {
	gB_ShowingInfoPanel[client] = ToggleOptionBool(client, gB_ShowingInfoPanel[client], "Option - Info Panel - Disable", "Option - Info Panel - Enable");
}

void ToggleShowWeapon(int client) {
	gB_ShowingWeapon[client] = ToggleOptionBool(client, gB_ShowingWeapon[client], "Option - Show Weapon - Disable", "Option - Show Weapon - Enable");
	SetDrawViewModel(client, gB_ShowingWeapon[client]);
}

void ToggleShowKeys(int client) {
	gB_ShowingKeys[client] = ToggleOptionBool(client, gB_ShowingKeys[client], "Option - Show Keys - Disable", "Option - Show Keys - Enable");
}

void ToggleAutoRestart(int client) {
	gB_AutoRestart[client] = ToggleOptionBool(client, gB_AutoRestart[client], "Option - Auto Restart - Disable", "Option - Auto Restart - Enable");
}

void ToggleSlayOnEnd(int client) {
	gB_SlayOnEnd[client] = ToggleOptionBool(client, gB_SlayOnEnd[client], "Option - Slay On End - Disable", "Option - Slay On End - Enable");
}

void ToggleCheckpointMessages(int client) {
	gB_CheckpointMessages[client] = ToggleOptionBool(client, gB_CheckpointMessages[client], "Option - Checkpoint Messages - Disable", "Option - Checkpoint Messages - Enable");
}

void ToggleCheckpointSounds(int client) {
	gB_CheckpointSounds[client] = ToggleOptionBool(client, gB_CheckpointSounds[client], "Option - Checkpoint Sounds - Disable", "Option - Checkpoint Sounds - Enable");
}

void ToggleTeleportSounds(int client) {
	gB_TeleportSounds[client] = ToggleOptionBool(client, gB_TeleportSounds[client], "Option - Teleport Sounds - Disable", "Option - Teleport Sounds - Enable");
} 