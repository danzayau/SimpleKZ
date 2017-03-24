/*	options.sp
	
	Player options.
*/


int GetOption(int client, KZOption option) {
	switch (option) {
		case KZOption_Style:return view_as<int>(g_Style[client]);
		case KZOption_ShowingTeleportMenu:return view_as<int>(g_ShowingTeleportMenu[client]);
		case KZOption_ShowingInfoPanel:return view_as<int>(g_ShowingInfoPanel[client]);
		case KZOption_ShowingKeys:return view_as<int>(g_ShowingKeys[client]);
		case KZOption_ShowingPlayers:return view_as<int>(g_ShowingPlayers[client]);
		case KZOption_ShowingWeapon:return view_as<int>(g_ShowingWeapon[client]);
		case KZOption_AutoRestart:return view_as<int>(g_AutoRestart[client]);
		case KZOption_SlayOnEnd:return view_as<int>(g_SlayOnEnd[client]);
		case KZOption_Pistol:return view_as<int>(g_Pistol[client]);
		case KZOption_CheckpointMessages:return view_as<int>(g_CheckpointMessages[client]);
		case KZOption_CheckpointSounds:return view_as<int>(g_CheckpointSounds[client]);
		case KZOption_TeleportSounds:return view_as<int>(g_TeleportSounds[client]);
		case KZOption_TimerText:return view_as<int>(g_TimerText[client]);
	}
	return -1;
}

void SetOption(int client, KZOption option, any optionValue) {
	// Checks if the option actually needs changing before changing it,
	// and performs actions required to apply those changes.
	// In most cases, no action is required.
	
	bool changedOption = false;
	
	switch (option) {
		case KZOption_Style: {
			if (g_Style[client] != optionValue) {
				changedOption = true;
				g_Style[client] = optionValue;
				if (gB_TimerRunning[client]) {
					TimerForceStop(client);
					CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped (Changed Style)");
				}
			}
		}
		case KZOption_ShowingTeleportMenu: {
			if (g_ShowingTeleportMenu[client] != optionValue) {
				changedOption = true;
				g_ShowingTeleportMenu[client] = optionValue;
				CloseTeleportMenu(client);
			}
		}
		case KZOption_ShowingInfoPanel: {
			if (g_ShowingInfoPanel[client] != optionValue) {
				changedOption = true;
				g_ShowingInfoPanel[client] = optionValue;
			}
		}
		case KZOption_ShowingKeys: {
			if (g_ShowingKeys[client] != optionValue) {
				changedOption = true;
				g_ShowingKeys[client] = optionValue;
			}
		}
		case KZOption_ShowingPlayers: {
			if (g_ShowingPlayers[client] != optionValue) {
				changedOption = true;
				g_ShowingPlayers[client] = optionValue;
			}
		}
		case KZOption_ShowingWeapon: {
			if (g_ShowingWeapon[client] != optionValue) {
				changedOption = true;
				g_ShowingWeapon[client] = optionValue;
				SetDrawViewModel(client, view_as<bool>(g_ShowingWeapon[client]));
			}
		}
		case KZOption_AutoRestart: {
			if (g_AutoRestart[client] != optionValue) {
				changedOption = true;
				g_AutoRestart[client] = optionValue;
			}
		}
		case KZOption_SlayOnEnd: {
			if (g_SlayOnEnd[client] != optionValue) {
				changedOption = true;
				g_SlayOnEnd[client] = optionValue;
			}
		}
		case KZOption_Pistol: {
			if (g_Pistol[client] != optionValue) {
				changedOption = true;
				g_Pistol[client] = optionValue;
				GivePlayerPistol(client, g_Pistol[client]);
			}
		}
		case KZOption_CheckpointMessages: {
			if (g_CheckpointMessages[client] != optionValue) {
				changedOption = true;
				g_CheckpointMessages[client] = optionValue;
			}
		}
		case KZOption_CheckpointSounds: {
			if (g_CheckpointSounds[client] != optionValue) {
				changedOption = true;
				g_CheckpointSounds[client] = optionValue;
			}
		}
		case KZOption_TeleportSounds: {
			if (g_TeleportSounds[client] != optionValue) {
				changedOption = true;
				g_TeleportSounds[client] = optionValue;
			}
		}
		case KZOption_TimerText: {
			if (g_TimerText[client] != optionValue) {
				changedOption = true;
				g_TimerText[client] = optionValue;
			}
		}
	}
	
	if (changedOption) {
		PrintOptionChangeMessage(client, option);
		Call_SimpleKZ_OnChangeOption(client, option, optionValue);
	}
}

void SetDefaultOptions(int client) {
	SetOption(client, KZOption_Style, view_as<KZStyle>(GetConVarInt(gCV_DefaultStyle)));
	SetOption(client, KZOption_ShowingTeleportMenu, KZShowingTeleportMenu_Enabled);
	SetOption(client, KZOption_ShowingKeys, KZShowingKeys_Disabled);
	SetOption(client, KZOption_ShowingPlayers, KZShowingPlayers_Enabled);
	SetOption(client, KZOption_ShowingWeapon, KZShowingWeapon_Enabled);
	SetOption(client, KZOption_AutoRestart, KZAutoRestart_Disabled);
	SetOption(client, KZOption_SlayOnEnd, KZSlayOnEnd_Disabled);
	SetOption(client, KZOption_Pistol, KZPistol_USP);
	SetOption(client, KZOption_CheckpointMessages, KZCheckpointMessages_Disabled);
	SetOption(client, KZOption_CheckpointSounds, KZCheckpointSounds_Disabled);
	SetOption(client, KZOption_TeleportSounds, KZTeleportSounds_Disabled);
	SetOption(client, KZOption_TimerText, KZTimerText_Disabled);
}

void IncrementOption(int client, KZOption option) {
	// Add 1 to the current value of the option
	// Modulo the result with the total number of that option which can be obtained by using view_as<int>(tag).
	switch (option) {
		case KZOption_Style: {
			SetOption(client, option, (view_as<int>(g_Style[client]) + 1) % view_as<int>(KZStyle));
		}
		case KZOption_ShowingTeleportMenu: {
			SetOption(client, option, (view_as<int>(g_ShowingTeleportMenu[client]) + 1) % view_as<int>(KZShowingTeleportMenu));
		}
		case KZOption_ShowingInfoPanel: {
			SetOption(client, option, (view_as<int>(g_ShowingInfoPanel[client]) + 1) % view_as<int>(KZShowingInfoPanel));
		}
		case KZOption_ShowingKeys: {
			SetOption(client, option, (view_as<int>(g_ShowingKeys[client]) + 1) % view_as<int>(KZShowingKeys));
		}
		case KZOption_ShowingPlayers: {
			SetOption(client, option, (view_as<int>(g_ShowingPlayers[client]) + 1) % view_as<int>(KZShowingPlayers));
		}
		case KZOption_ShowingWeapon: {
			SetOption(client, option, (view_as<int>(g_ShowingWeapon[client]) + 1) % view_as<int>(KZShowingWeapon));
		}
		case KZOption_AutoRestart: {
			SetOption(client, option, (view_as<int>(g_AutoRestart[client]) + 1) % view_as<int>(KZAutoRestart));
		}
		case KZOption_SlayOnEnd: {
			SetOption(client, option, (view_as<int>(g_SlayOnEnd[client]) + 1) % view_as<int>(KZSlayOnEnd));
		}
		case KZOption_Pistol: {
			SetOption(client, option, (view_as<int>(g_Pistol[client]) + 1) % view_as<int>(KZPistol));
		}
		case KZOption_CheckpointMessages: {
			SetOption(client, option, (view_as<int>(g_CheckpointMessages[client]) + 1) % view_as<int>(KZCheckpointMessages));
		}
		case KZOption_CheckpointSounds: {
			SetOption(client, option, (view_as<int>(g_CheckpointSounds[client]) + 1) % view_as<int>(KZCheckpointSounds));
		}
		case KZOption_TeleportSounds: {
			SetOption(client, option, (view_as<int>(g_TeleportSounds[client]) + 1) % view_as<int>(KZTeleportSounds));
		}
		case KZOption_TimerText: {
			SetOption(client, option, (view_as<int>(g_TimerText[client]) + 1) % view_as<int>(KZTimerText));
		}
	}
}

void PrintOptionChangeMessage(int client, KZOption option) {
	if (!IsClientInGame(client)) {
		return;
	}
	
	// NOTE: Not all options have a message for when they are changed.
	switch (option) {
		case KZOption_Style: {
			CPrintToChat(client, "%t %t", "KZ Prefix", "Switched Style", gC_StylePhrases[g_Style[client]]);
		}
		case KZOption_ShowingTeleportMenu: {
			switch (g_ShowingTeleportMenu[client]) {
				case KZShowingTeleportMenu_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Disable");
				}
				case KZShowingTeleportMenu_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Enable");
				}
			}
		}
		case KZOption_ShowingInfoPanel: {
			switch (g_ShowingInfoPanel[client]) {
				case KZShowingInfoPanel_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Disable");
				}
				case KZShowingInfoPanel_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Enable");
				}
			}
		}
		case KZOption_ShowingKeys: {
			switch (g_ShowingKeys[client]) {
				case KZShowingKeys_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Keys - Disable");
				}
				case KZShowingKeys_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Keys - Enable");
				}
			}
		}
		case KZOption_ShowingPlayers: {
			switch (g_ShowingPlayers[client]) {
				case KZShowingPlayers_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Disable");
				}
				case KZShowingPlayers_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Enable");
				}
			}
		}
		case KZOption_ShowingWeapon: {
			switch (g_ShowingPlayers[client]) {
				case KZShowingPlayers_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Disable");
				}
				case KZShowingPlayers_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Enable");
				}
			}
		}
		case KZOption_AutoRestart: {
			switch (g_AutoRestart[client]) {
				case KZAutoRestart_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Disable");
				}
				case KZAutoRestart_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Enable");
				}
			}
		}
		case KZOption_SlayOnEnd: {
			switch (g_SlayOnEnd[client]) {
				case KZSlayOnEnd_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Disable");
				}
				case KZSlayOnEnd_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Enable");
				}
			}
		}
		case KZOption_CheckpointMessages: {
			switch (g_CheckpointMessages[client]) {
				case KZSlayOnEnd_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Disable");
				}
				case KZSlayOnEnd_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Enable");
				}
			}
		}
		case KZOption_CheckpointSounds: {
			switch (g_CheckpointSounds[client]) {
				case KZCheckpointMessages_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Checkpoint Sounds - Disable");
				}
				case KZCheckpointMessages_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Checkpoint Sounds - Enable");
				}
			}
		}
		case KZOption_TeleportSounds: {
			switch (g_TeleportSounds[client]) {
				case KZTeleportSounds_Disabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Sounds - Disable");
				}
				case KZTeleportSounds_Enabled: {
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Sounds - Enable");
				}
			}
		}
	}
} 