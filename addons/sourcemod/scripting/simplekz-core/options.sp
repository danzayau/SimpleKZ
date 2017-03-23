/*	options.sp
	
	Player options.
*/


int GetOption(int client, KZOption option) {
	switch (option) {
		case KZOption_Style:return view_as<int>(g_Style[client]);
		case KZOption_ShowingTeleportMenu:return gI_ShowingTeleportMenu[client];
		case KZOption_ShowingInfoPanel:return gI_ShowingInfoPanel[client];
		case KZOption_ShowingKeys:return gI_ShowingKeys[client];
		case KZOption_ShowingPlayers:return gI_ShowingPlayers[client];
		case KZOption_ShowingWeapon:return gI_ShowingWeapon[client];
		case KZOption_AutoRestart:return gI_AutoRestart[client];
		case KZOption_SlayOnEnd:return gI_SlayOnEnd[client];
		case KZOption_Pistol:return gI_Pistol[client];
		case KZOption_CheckpointMessages:return gI_CheckpointMessages[client];
		case KZOption_CheckpointSounds:return gI_CheckpointSounds[client];
		case KZOption_TeleportSounds:return gI_TeleportSounds[client];
		case KZOption_TimerText:return gI_TimerText[client];
	}
	return -1;
}

void SetOption(int client, KZOption option, any optionValue) {
	switch (option) {
		case KZOption_Style:g_Style[client] = view_as<KZMovementStyle>(optionValue);
		case KZOption_ShowingTeleportMenu:gI_ShowingTeleportMenu[client] = view_as<int>(optionValue);
		case KZOption_ShowingInfoPanel:gI_ShowingInfoPanel[client] = view_as<int>(optionValue);
		case KZOption_ShowingKeys:gI_ShowingKeys[client] = view_as<int>(optionValue);
		case KZOption_ShowingPlayers:gI_ShowingPlayers[client] = view_as<int>(optionValue);
		case KZOption_ShowingWeapon:gI_ShowingWeapon[client] = view_as<int>(optionValue);
		case KZOption_AutoRestart:gI_AutoRestart[client] = view_as<int>(optionValue);
		case KZOption_SlayOnEnd:gI_SlayOnEnd[client] = view_as<int>(optionValue);
		case KZOption_Pistol:gI_Pistol[client] = view_as<int>(optionValue);
		case KZOption_CheckpointMessages:gI_CheckpointMessages[client] = view_as<int>(optionValue);
		case KZOption_CheckpointSounds:gI_CheckpointSounds[client] = view_as<int>(optionValue);
		case KZOption_TeleportSounds:gI_TeleportSounds[client] = view_as<int>(optionValue);
		case KZOption_TimerText:gI_TimerText[client] = view_as<int>(optionValue);
	}
}

void SetDefaultOptions(int client) {
	g_Style[client] = view_as<KZMovementStyle>(GetConVarInt(gCV_DefaultStyle));
	gI_ShowingTeleportMenu[client] = SIMPLEKZ_OPTION_ENABLED;
	gI_ShowingInfoPanel[client] = SIMPLEKZ_OPTION_ENABLED;
	gI_ShowingKeys[client] = SIMPLEKZ_OPTION_DISABLED;
	gI_ShowingPlayers[client] = SIMPLEKZ_OPTION_ENABLED;
	gI_ShowingWeapon[client] = SIMPLEKZ_OPTION_ENABLED;
	gI_AutoRestart[client] = SIMPLEKZ_OPTION_DISABLED;
	gI_SlayOnEnd[client] = SIMPLEKZ_OPTION_DISABLED;
	gI_Pistol[client] = DEFAULT_PISTOL;
	gI_CheckpointMessages[client] = SIMPLEKZ_OPTION_DISABLED;
	gI_CheckpointSounds[client] = SIMPLEKZ_OPTION_DISABLED;
	gI_TeleportSounds[client] = SIMPLEKZ_OPTION_DISABLED;
	gI_TimerText[client] = SIMPLEKZ_TIMERTEXT_DISABLED;
}

// Toggle option between enabled and disabled, and print the related phrases to chat
int ToggleOption(int client, int option, const char[] disablePhrase, const char[] enablePhrase) {
	if (option == SIMPLEKZ_OPTION_ENABLED) {
		CPrintToChat(client, "%t %t", "KZ Prefix", disablePhrase);
		return SIMPLEKZ_OPTION_DISABLED;
	}
	CPrintToChat(client, "%t %t", "KZ Prefix", enablePhrase);
	return SIMPLEKZ_OPTION_ENABLED;
}

// Increment an option variable. Resets to 0 if the new value exceeds maximumValue.
int IncrementOption(int option, int maximumValue) {
	int newValue = option;
	newValue++;
	if (newValue > maximumValue) {
		newValue = 0;
	}
	return newValue;
}

void ToggleTeleportMenu(int client) {
	gI_ShowingTeleportMenu[client] = ToggleOption(client, gI_ShowingTeleportMenu[client], "Option - Teleport Menu - Disable", "Option - Teleport Menu - Enable");
	CloseTeleportMenu(client);
}

void ToggleShowPlayers(int client) {
	gI_ShowingPlayers[client] = ToggleOption(client, gI_ShowingPlayers[client], "Option - Show Players - Disable", "Option - Show Players - Enable");
}

void ToggleInfoPanel(int client) {
	gI_ShowingInfoPanel[client] = ToggleOption(client, gI_ShowingInfoPanel[client], "Option - Info Panel - Disable", "Option - Info Panel - Enable");
}

void ToggleShowWeapon(int client) {
	gI_ShowingWeapon[client] = ToggleOption(client, gI_ShowingWeapon[client], "Option - Show Weapon - Disable", "Option - Show Weapon - Enable");
	SetDrawViewModel(client, view_as<bool>(gI_ShowingWeapon[client]));
}

void ToggleShowKeys(int client) {
	gI_ShowingKeys[client] = ToggleOption(client, gI_ShowingKeys[client], "Option - Show Keys - Disable", "Option - Show Keys - Enable");
}

void ToggleAutoRestart(int client) {
	gI_AutoRestart[client] = ToggleOption(client, gI_AutoRestart[client], "Option - Auto Restart - Disable", "Option - Auto Restart - Enable");
}

void ToggleSlayOnEnd(int client) {
	gI_SlayOnEnd[client] = ToggleOption(client, gI_SlayOnEnd[client], "Option - Slay On End - Disable", "Option - Slay On End - Enable");
}

void ToggleCheckpointMessages(int client) {
	gI_CheckpointMessages[client] = ToggleOption(client, gI_CheckpointMessages[client], "Option - Checkpoint Messages - Disable", "Option - Checkpoint Messages - Enable");
}

void ToggleCheckpointSounds(int client) {
	gI_CheckpointSounds[client] = ToggleOption(client, gI_CheckpointSounds[client], "Option - Checkpoint Sounds - Disable", "Option - Checkpoint Sounds - Enable");
}

void ToggleTeleportSounds(int client) {
	gI_TeleportSounds[client] = ToggleOption(client, gI_TeleportSounds[client], "Option - Teleport Sounds - Disable", "Option - Teleport Sounds - Enable");
}

void IncrementTimerText(int client) {
	gI_TimerText[client] = IncrementOption(gI_TimerText[client], 3);
} 