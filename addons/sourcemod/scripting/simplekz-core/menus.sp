/*	menus.sp
	
	Menus in SimpleKZ.
*/


void CreateMenus() {
	CreateTeleportMenuAll();
	CreateOptionsMenuAll();
	CreateMovementStyleMenuAll();
	CreatePistolMenuAll();
	CreateMeasureMenuAll();
}


/*===============================  Teleport Menu  ===============================*/

void CreateTeleportMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateTeleportMenu(client);
	}
}

void CreateTeleportMenu(int client) {
	gH_TeleportMenu[client] = CreateMenu(MenuHandler_TeleportMenu);
	SetMenuOptionFlags(gH_TeleportMenu[client], MENUFLAG_NO_SOUND);
	SetMenuExitButton(gH_TeleportMenu[client], false);
}

void UpdateTeleportMenu(int client) {
	if (GetClientMenu(client) == MenuSource_None && gI_ShowingTeleportMenu[client] && !gB_TeleportMenuIsShowing[client] && IsPlayerAlive(client)) {
		UpdateTeleportMenuItems(client);
		DisplayMenu(gH_TeleportMenu[client], client, MENU_TIME_FOREVER);
		gB_TeleportMenuIsShowing[client] = true;
	}
}

public int MenuHandler_TeleportMenu(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:MakeCheckpoint(param1);
			case 1:TeleportToCheckpoint(param1);
			case 2:TogglePause(param1);
			case 3:TeleportToStart(param1);
			case 4:UndoTeleport(param1);
		}
	}
	else if (action == MenuAction_Cancel) {
		gB_TeleportMenuIsShowing[param1] = false;
	}
}

void CloseTeleportMenu(int client) {
	// Closing the teleport menu makes it refresh
	if (gB_TeleportMenuIsShowing[client]) {
		CancelClientMenu(client);
		gB_TeleportMenuIsShowing[client] = false;
	}
}

void TeleportAddItems(int client) {
	TeleportAddItemCheckpoint(client);
	TeleportAddItemTeleport(client);
	TeleportAddItemPause(client);
	TeleportAddItemStart(client);
	TeleportAddItemUndo(client);
}

void UpdateTeleportMenuItems(int client) {
	RemoveAllMenuItems(gH_TeleportMenu[client]);
	TeleportAddItems(client);
}

void TeleportAddItemCheckpoint(int client) {
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Checkpoint", client);
	AddMenuItem(gH_TeleportMenu[client], "", text);
}

void TeleportAddItemTeleport(int client) {
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Teleport", client);
	if (gI_CheckpointCount[client] > 0) {
		AddMenuItem(gH_TeleportMenu[client], "", text);
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "", text, ITEMDRAW_DISABLED);
	}
}

void TeleportAddItemUndo(int client) {
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Undo TP", client);
	if (gI_TeleportsUsed[client] > 0 && gB_LastTeleportOnGround[client]) {
		AddMenuItem(gH_TeleportMenu[client], "", text);
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "", text, ITEMDRAW_DISABLED);
	}
}

void TeleportAddItemPause(int client) {
	char text[16];
	if (!gB_Paused[client]) {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Pause", client);
		AddMenuItem(gH_TeleportMenu[client], "", text);
	}
	else {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Resume", client);
		AddMenuItem(gH_TeleportMenu[client], "", text);
	}
}

void TeleportAddItemStart(int client) {
	char text[16];
	if (gB_HasStartedThisMap[client]) {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Restart", client);
		AddMenuItem(gH_TeleportMenu[client], "", text);
	}
	else {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Respawn", client);
		AddMenuItem(gH_TeleportMenu[client], "", text);
	}
}



/*===============================  Options Menu ===============================*/

void CreateOptionsMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateOptionsMenu(client);
	}
}

void CreateOptionsMenu(int client) {
	gH_OptionsMenu[client] = CreateMenu(MenuHandler_Options);
	SetMenuPagination(gH_OptionsMenu[client], 6);
}

void DisplayOptionsMenu(int client, int atItem = 0) {
	UpdateOptionsMenu(client);
	DisplayMenuAtItem(gH_OptionsMenu[client], client, atItem, MENU_TIME_FOREVER);
}

void UpdateOptionsMenu(int client) {
	SetMenuTitle(gH_OptionsMenu[client], "%T", "Options Menu - Title", client);
	RemoveAllMenuItems(gH_OptionsMenu[client]);
	OptionsAddToggle(client, gI_ShowingTeleportMenu[client], "Options Menu - Teleport Menu");
	OptionsAddToggle(client, gI_ShowingInfoPanel[client], "Options Menu - Info Panel");
	OptionsAddToggle(client, gI_ShowingPlayers[client], "Options Menu - Show Players");
	OptionsAddToggle(client, gI_ShowingWeapon[client], "Options Menu - Show Weapon");
	OptionsAddToggle(client, gI_AutoRestart[client], "Options Menu - Auto Restart");
	OptionsAddPistol(client);
	OptionsAddToggle(client, gI_SlayOnEnd[client], "Options Menu - Slay On End");
	OptionsAddToggle(client, gI_ShowingKeys[client], "Options Menu - Show Keys");
	OptionsAddToggle(client, gI_CheckpointMessages[client], "Options Menu - Checkpoint Messages");
	OptionsAddToggle(client, gI_CheckpointSounds[client], "Options Menu - Checkpoint Sounds");
	OptionsAddToggle(client, gI_TeleportSounds[client], "Options Menu - Teleport Sounds");
	OptionsAddTimerText(client);
}

void OptionsAddToggle(int client, int option, const char[] optionPhrase) {
	char text[32];
	if (option == SIMPLEKZ_OPTION_ENABLED) {
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Enabled", client);
		AddMenuItem(gH_OptionsMenu[client], "", text);
	}
	else {
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Disabled", client);
		AddMenuItem(gH_OptionsMenu[client], "", text);
	}
}

void OptionsAddPistol(int client) {
	char text[32];
	FormatEx(text, sizeof(text), "%T - %s", "Options Menu - Pistol", client, gC_Pistols[gI_Pistol[client]][1]);
	AddMenuItem(gH_OptionsMenu[client], "", text);
}

void OptionsAddTimerText(int client) {
	char text[32];
	FormatEx(text, sizeof(text), "%T - %T", "Options Menu - Timer Text", client, gC_TimerTextOptionPhrases[gI_TimerText[client]], client);
	AddMenuItem(gH_OptionsMenu[client], "", text);
}

public int MenuHandler_Options(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:ToggleTeleportMenu(param1);
			case 1:ToggleInfoPanel(param1);
			case 2:ToggleShowPlayers(param1);
			case 3:ToggleShowWeapon(param1);
			case 4:ToggleAutoRestart(param1);
			case 5: {
				gB_CameFromOptionsMenu[param1] = true;
				DisplayPistolMenu(param1);
			}
			case 6:ToggleSlayOnEnd(param1);
			case 7:ToggleShowKeys(param1);
			case 8:ToggleCheckpointMessages(param1);
			case 9:ToggleCheckpointSounds(param1);
			case 10:ToggleTeleportSounds(param1);
			case 11:IncrementTimerText(param1);
		}
		if (param2 != 5) {
			// Reopen the menu at the same place
			DisplayOptionsMenu(param1, param2 / 6 * 6); // Round item number down to multiple of 6
		}
	}
}



/*===============================  Movement Style Menu  ===============================*/

void CreateMovementStyleMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateMovementStyleMenu(client);
	}
}

void CreateMovementStyleMenu(int client) {
	gH_MovementStyleMenu[client] = CreateMenu(MenuHandler_MovementStyle);
}

void DisplayMovementStyleMenu(int client) {
	SetMenuTitle(gH_MovementStyleMenu[client], "%T", "Style Menu - Title", client);
	AddItemsMovementStyleMenu(client);
	DisplayMenu(gH_MovementStyleMenu[client], client, MENU_TIME_FOREVER);
}

void AddItemsMovementStyleMenu(int client) {
	char text[32];
	RemoveAllMenuItems(gH_MovementStyleMenu[client]);
	for (int style = 0; style < SIMPLEKZ_NUMBER_OF_STYLES; style++) {
		FormatEx(text, sizeof(text), "%T", gC_StylePhrases[style], client);
		AddMenuItem(gH_MovementStyleMenu[client], "", text, ITEMDRAW_DEFAULT);
	}
}

public int MenuHandler_MovementStyle(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:SetMovementStyle(param1, KZMovementStyle_Standard);
			case 1:SetMovementStyle(param1, KZMovementStyle_Legacy);
		}
	}
}



/*===============================  Pistol Menu ===============================*/

void CreatePistolMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreatePistolMenu(client);
	}
}

void CreatePistolMenu(int client) {
	gH_PistolMenu[client] = CreateMenu(MenuHandler_Pistol);
}

void DisplayPistolMenu(int client) {
	DisplayMenu(gH_PistolMenu[client], client, MENU_TIME_FOREVER);
}

void UpdatePistolMenu(int client) {
	SetMenuTitle(gH_PistolMenu[client], "%T", "Pistol Menu - Title", client);
	RemoveAllMenuItems(gH_PistolMenu[client]);
	for (int pistol = 0; pistol < sizeof(gC_Pistols); pistol++) {
		AddMenuItem(gH_PistolMenu[client], "", gC_Pistols[pistol][1]);
	}
}

public int MenuHandler_Pistol(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		gI_Pistol[param1] = param2;
		GivePlayerPistol(param1, param2);
		DisplayPistolMenu(param1);
	}
	else if (action == MenuAction_Cancel && gB_CameFromOptionsMenu[param1]) {
		gB_CameFromOptionsMenu[param1] = false;
		DisplayOptionsMenu(param1);
	}
}



/*===============================  Measure Menu ===============================*/
// Credits to DaFox (https://forums.alliedmods.net/showthread.php?t=88830?t=88830)

void CreateMeasureMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateMeasureMenu(client);
	}
}

void CreateMeasureMenu(int client) {
	gH_MeasureMenu[client] = CreateMenu(MenuHandler_Measure);
}

void DisplayMeasureMenu(int client) {
	DisplayMenu(gH_MeasureMenu[client], client, MENU_TIME_FOREVER);
}

void UpdateMeasureMenu(int client) {
	SetMenuTitle(gH_MeasureMenu[client], "%T", "Measure Menu - Title", client);
	
	char text[32];
	RemoveAllMenuItems(gH_MeasureMenu[client]);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point A", client);
	AddMenuItem(gH_MeasureMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point B", client);
	AddMenuItem(gH_MeasureMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Get Distance", client);
	AddMenuItem(gH_MeasureMenu[client], "", text);
}

public int MenuHandler_Measure(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0: {  //Point A (Green)
				MeasureGetPos(param1, 0);
			}
			case 1: {  //Point B (Red)
				MeasureGetPos(param1, 1);
			}
			case 2: {  //Find Distance
				if (gB_MeasurePosSet[param1][0] && gB_MeasurePosSet[param1][1]) {
					float vDist = GetVectorDistance(gF_MeasurePos[param1][0], gF_MeasurePos[param1][1]);
					float vHightDist = (gF_MeasurePos[param1][1][2] - gF_MeasurePos[param1][0][2]);
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Result", vDist, vHightDist);
					MeasureBeam(param1, gF_MeasurePos[param1][0], gF_MeasurePos[param1][1], 5.0, 2.0, 200, 200, 200);
				}
				else {
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Failure (Points Not Set)");
				}
			}
		}
		DisplayMenu(gH_MeasureMenu[param1], param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel) {
		MeasureResetPos(param1);
	}
}

void MeasureGetPos(int client, int arg) {
	float origin[3];
	float angles[3];
	
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angles);
	
	Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SHOT, RayType_Infinite, TraceFilterPlayers, client);
	
	if (!TR_DidHit(trace)) {
		CloseHandle(trace);
		CPrintToChat(client, "%t %t", "KZ Prefix", "Measure Failure (Not Aiming at Solid)");
		return;
	}
	
	TR_GetEndPosition(origin, trace);
	CloseHandle(trace);
	
	gF_MeasurePos[client][arg][0] = origin[0];
	gF_MeasurePos[client][arg][1] = origin[1];
	gF_MeasurePos[client][arg][2] = origin[2];
	
	if (arg == 0) {
		if (gH_P2PRed[client] != INVALID_HANDLE) {
			CloseHandle(gH_P2PRed[client]);
			gH_P2PRed[client] = INVALID_HANDLE;
		}
		gB_MeasurePosSet[client][0] = true;
		gH_P2PRed[client] = CreateTimer(1.0, Timer_P2PRed, client, TIMER_REPEAT);
		P2PXBeam(client, 0);
	}
	else {
		if (gH_P2PGreen[client] != INVALID_HANDLE) {
			CloseHandle(gH_P2PGreen[client]);
			gH_P2PGreen[client] = INVALID_HANDLE;
		}
		gB_MeasurePosSet[client][1] = true;
		P2PXBeam(client, 1);
		gH_P2PGreen[client] = CreateTimer(1.0, Timer_P2PGreen, client, TIMER_REPEAT);
	}
}

public Action Timer_P2PRed(Handle timer, int client) {
	if (IsValidClient(client)) {
		P2PXBeam(client, 0);
	}
}

public Action Timer_P2PGreen(Handle timer, int client) {
	if (IsValidClient(client)) {
		P2PXBeam(client, 1);
	}
}

void P2PXBeam(int client, int arg) {
	float Origin0[3];
	float Origin1[3];
	float Origin2[3];
	float Origin3[3];
	
	Origin0[0] = (gF_MeasurePos[client][arg][0] + 8.0);
	Origin0[1] = (gF_MeasurePos[client][arg][1] + 8.0);
	Origin0[2] = gF_MeasurePos[client][arg][2];
	
	Origin1[0] = (gF_MeasurePos[client][arg][0] - 8.0);
	Origin1[1] = (gF_MeasurePos[client][arg][1] - 8.0);
	Origin1[2] = gF_MeasurePos[client][arg][2];
	
	Origin2[0] = (gF_MeasurePos[client][arg][0] + 8.0);
	Origin2[1] = (gF_MeasurePos[client][arg][1] - 8.0);
	Origin2[2] = gF_MeasurePos[client][arg][2];
	
	Origin3[0] = (gF_MeasurePos[client][arg][0] - 8.0);
	Origin3[1] = (gF_MeasurePos[client][arg][1] + 8.0);
	Origin3[2] = gF_MeasurePos[client][arg][2];
	
	if (arg == 0) {
		MeasureBeam(client, Origin0, Origin1, 0.97, 2.0, 0, 255, 0);
		MeasureBeam(client, Origin2, Origin3, 0.97, 2.0, 0, 255, 0);
	}
	else {
		MeasureBeam(client, Origin0, Origin1, 0.97, 2.0, 255, 0, 0);
		MeasureBeam(client, Origin2, Origin3, 0.97, 2.0, 255, 0, 0);
	}
}

void MeasureBeam(int client, float vecStart[3], float vecEnd[3], float life, float width, int r, int g, int b) {
	TE_Start("BeamPoints");
	TE_WriteNum("m_nModelIndex", gI_GlowSprite);
	TE_WriteNum("m_nHaloIndex", 0);
	TE_WriteNum("m_nStartFrame", 0);
	TE_WriteNum("m_nFrameRate", 0);
	TE_WriteFloat("m_fLife", life);
	TE_WriteFloat("m_fWidth", width);
	TE_WriteFloat("m_fEndWidth", width);
	TE_WriteNum("m_nFadeLength", 0);
	TE_WriteFloat("m_fAmplitude", 0.0);
	TE_WriteNum("m_nSpeed", 0);
	TE_WriteNum("r", r);
	TE_WriteNum("g", g);
	TE_WriteNum("b", b);
	TE_WriteNum("a", 255);
	TE_WriteNum("m_nFlags", 0);
	TE_WriteVector("m_vecStartPoint", vecStart);
	TE_WriteVector("m_vecEndPoint", vecEnd);
	TE_SendToClient(client);
}

void MeasureResetPos(int client) {
	if (gH_P2PRed[client] != INVALID_HANDLE) {
		CloseHandle(gH_P2PRed[client]);
		gH_P2PRed[client] = INVALID_HANDLE;
	}
	if (gH_P2PGreen[client] != INVALID_HANDLE) {
		CloseHandle(gH_P2PGreen[client]);
		gH_P2PGreen[client] = INVALID_HANDLE;
	}
	gB_MeasurePosSet[client][0] = false;
	gB_MeasurePosSet[client][1] = false;
	
	gF_MeasurePos[client][0][0] = 0.0; //This is stupid.
	gF_MeasurePos[client][0][1] = 0.0;
	gF_MeasurePos[client][0][2] = 0.0;
	gF_MeasurePos[client][1][0] = 0.0;
	gF_MeasurePos[client][1][1] = 0.0;
	gF_MeasurePos[client][1][2] = 0.0;
}

public bool TraceFilterPlayers(int entity, int contentsMask) {
	return (entity > MaxClients);
} 