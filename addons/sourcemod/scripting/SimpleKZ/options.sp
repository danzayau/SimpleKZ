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
}

void ToggleTeleportMenu(int client) {
	if (gB_ShowingTeleportMenu[client]) {
		gB_ShowingTeleportMenu[client] = false;
		CloseTeleportMenu(client);
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Disable");
	}
	else {
		gB_ShowingTeleportMenu[client] = true;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Enable");
	}
}

void ToggleShowPlayers(int client) {
	if (gB_ShowingPlayers[client]) {
		gB_ShowingPlayers[client] = false;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Disable");
	}
	else {
		gB_ShowingPlayers[client] = true;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Enable");
	}
}

void ToggleInfoPanel(int client) {
	if (gB_ShowingInfoPanel[client]) {
		gB_ShowingInfoPanel[client] = false;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Disable");
	}
	else {
		gB_ShowingInfoPanel[client] = true;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Enable");
	}
}

void ToggleShowWeapon(int client) {
	if (gB_ShowingWeapon[client]) {
		gB_ShowingWeapon[client] = false;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Weapon - Disable");
	}
	else {
		gB_ShowingWeapon[client] = true;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Weapon - Enable");
	}
	SetDrawViewModel(client, gB_ShowingWeapon[client]);
}

void ToggleShowKeys(int client) {
	if (gB_ShowingKeys[client]) {
		gB_ShowingKeys[client] = false;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Keys - Disable");
	}
	else {
		gB_ShowingKeys[client] = true;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Keys - Enable");
	}
}

void ToggleAutoRestart(int client) {
	if (gB_AutoRestart[client]) {
		gB_AutoRestart[client] = false;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Disable");
	}
	else {
		gB_AutoRestart[client] = true;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Enable");
	}
}

void ToggleSlayOnEnd(int client) {
	if (gB_SlayOnEnd[client]) {
		gB_SlayOnEnd[client] = false;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Disable");
	}
	else {
		gB_SlayOnEnd[client] = true;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Enable");
	}
} 