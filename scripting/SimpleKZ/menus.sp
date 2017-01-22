/*	infopanel.sp
	
	Menus in SimpleKZ.
*/


void SetupMenus() {
	SetupTeleportMenuAll();
	SetupMeasureMenu();
	SetupPistolMenu();
	SetupMapTopMenuAll();
}



/*===============================  Teleport Menu  ===============================*/

void SetupTeleportMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		SetupTeleportMenu(client);
	}
}

void SetupTeleportMenu(int client) {
	gH_TeleportMenu[client] = CreateMenu(MenuHandler_Timer);
	SetMenuExitButton(gH_TeleportMenu[client], false);
	SetMenuOptionFlags(gH_TeleportMenu[client], MENUFLAG_NO_SOUND);
}

void UpdateTeleportMenu(int client) {
	if (GetClientMenu(client) == MenuSource_None && gB_ShowingTeleportMenu[client] && !gB_TeleportMenuIsShowing[client]) {
		UpdateTeleportMenuItems(client);
		DisplayMenu(gH_TeleportMenu[client], client, MENU_TIME_FOREVER);
		gB_TeleportMenuIsShowing[client] = true;
	}
}

public int MenuHandler_Timer(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		if (IsPlayerAlive(param1)) {
			switch (param2) {
				case 0:MakeCheckpoint(param1);
				case 1:TeleportToCheckpoint(param1);
				case 2:TogglePause(param1);
				case 3:TeleportToStart(param1);
				case 4:UndoTeleport(param1);
			}
		}
		else {
			switch (param2) {
				case 0:JoinTeam(param1, CS_TEAM_CT);
			}
		}
	}
	else if (action == MenuAction_Cancel) {
		gB_TeleportMenuIsShowing[param1] = false;
	}
}

void CloseTeleportMenu(int client) {
	if (gB_TeleportMenuIsShowing[client]) {
		CancelClientMenu(client);
		gB_TeleportMenuIsShowing[client] = false;
	}
}

void TeleportMenuAddItems(int client) {
	if (IsPlayerAlive(client)) {
		SetMenuTitle(gH_TeleportMenu[client], "");
		TeleportMenuAddItemCheckpoint(client);
		TeleportMenuAddItemTeleport(client);
		TeleportMenuAddItemPause(client);
		TeleportMenuAddItemStart(client);
		TeleportMenuAddItemUndo(client);
	}
	else {
		if (gB_TimerRunning[client]) {
			SetMenuTitle(gH_TeleportMenu[client], "PAUSED\n%s %s", 
				GetCurrentRunTypeString(gI_TeleportsUsed[client]), 
				FormatTimeFloat(gF_CurrentTime[client]));
		}
		TeleportMenuAddItemRejoin(client);
	}
}

void UpdateTeleportMenuItems(int client) {
	RemoveAllMenuItems(gH_TeleportMenu[client]);
	TeleportMenuAddItems(client);
}

void TeleportMenuAddItemCheckpoint(int client) {
	AddMenuItem(gH_TeleportMenu[client], "", "Checkpoint");
}

void TeleportMenuAddItemTeleport(int client) {
	if (gI_CheckpointsSet[client] > 0) {
		AddMenuItem(gH_TeleportMenu[client], "", "Teleport");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "", "Teleport", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemUndo(int client) {
	if (gI_TeleportsUsed[client] > 0 && gB_LastTeleportOnGround[client]) {
		AddMenuItem(gH_TeleportMenu[client], "", "Undo TP");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "", "Undo TP", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemPause(int client) {
	if (gB_TimerRunning[client]) {
		if (!gB_Paused[client]) {
			AddMenuItem(gH_TeleportMenu[client], "", "Pause");
		}
		else {
			AddMenuItem(gH_TeleportMenu[client], "", "Resume");
		}
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "", "Pause", ITEMDRAW_DISABLED);
	}
}

void TeleportMenuAddItemStart(int client) {
	if (gB_HasStartPosition[client]) {
		AddMenuItem(gH_TeleportMenu[client], "", "Restart");
	}
	else {
		AddMenuItem(gH_TeleportMenu[client], "", "Respawn");
	}
}

void TeleportMenuAddItemRejoin(int client) {
	AddMenuItem(gH_TeleportMenu[client], "", "Rejoin");
}



/*===============================  Pistol Menu ===============================*/

// Pistol Entity Names (entity class name, alias, team that buys it)
char gC_Pistols[NUMBER_OF_PISTOLS][3][] = 
{
	{ "weapon_hkp2000", "P2000 / USP-S", "CT" }, 
	{ "weapon_glock", "Glock-18", "T" }, 
	{ "weapon_p250", "P250", "EITHER" }, 
	{ "weapon_elite", "Dual Berettas", "EITHER" }, 
	{ "weapon_deagle", "Deagle", "EITHER" }, 
	{ "weapon_cz75a", "CZ75-Auto", "EITHER" }, 
	{ "weapon_fiveseven", "Five-SeveN", "CT" }, 
	{ "weapon_tec9", "Tec-9", "T" }
};

void SetupPistolMenu() {
	gH_PistolMenu = CreateMenu(MenuHandler_Pistol);
	SetMenuTitle(gH_PistolMenu, "Pick a Pistol");
	for (int pistol = 0; pistol < NUMBER_OF_PISTOLS; pistol++) {
		AddMenuItem(gH_PistolMenu, "", gC_Pistols[pistol][1]);
	}
}

public int MenuHandler_Pistol(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		gI_Pistol[param1] = param2;
		GivePlayerPistol(param1, param2);
	}
}

void GivePlayerPistol(int client, int pistol) {
	int playerTeam = GetClientTeam(client);
	// Switch teams to the side that buys that gun so that gun skins load
	if (strcmp(gC_Pistols[pistol][2], "CT") == 0 && playerTeam != CS_TEAM_CT) {
		CS_SwitchTeam(client, CS_TEAM_CT);
	}
	else if (strcmp(gC_Pistols[pistol][2], "T") == 0 && playerTeam != CS_TEAM_T) {
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	// Give the player this pistol
	int currentPistol = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (currentPistol != -1) {
		RemovePlayerItem(client, currentPistol);
	}
	GivePlayerItem(client, gC_Pistols[pistol][0]);
	// Go back to original team
	if (1 <= playerTeam && playerTeam <= 3) {
		CS_SwitchTeam(client, playerTeam);
	}
}



/*===============================  Measure Menu ===============================*/
// Credits to DaFox (https://forums.alliedmods.net/showthread.php?t=88830?t=88830)

void SetupMeasureMenu() {
	gH_MeasureMenu = CreateMenu(MenuHandler_Measure);
	SetMenuTitle(gH_MeasureMenu, "Measure");
	AddMenuItem(gH_MeasureMenu, "", "Point A (Green)");
	AddMenuItem(gH_MeasureMenu, "", "Point B (Red)");
	AddMenuItem(gH_MeasureMenu, "", "Find Distance");
	AddMenuItem(gH_MeasureMenu, "", "Reset");
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
					PrintToChat(param1, "[\x06KZ\x01] Distance: %.2f, Vertical: %.2f.", vDist, vHightDist);
					
					MeasureBeam(param1, gF_MeasurePos[param1][0], gF_MeasurePos[param1][1], 5.0, 2.0, 200, 200, 200);
				}
				else {
					PrintToChat(param1, "[\x06KZ\x01] You must set both points to measure a distance.");
				}
			}
			case 3: {  //Reset
				MeasureResetPos(param1);
			}
		}
		DisplayMenu(gH_MeasureMenu, param1, MENU_TIME_FOREVER);
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
		PrintToChat(client, "[\x06KZ\x01] You are not aiming at anything solid!");
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
	P2PXBeam(client, 0);
}

public Action Timer_P2PGreen(Handle timer, int client) {
	P2PXBeam(client, 1);
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



/*===============================  MapTop Menu ===============================*/

void SetupMapTopMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		SetupMapTopMenu(client);
		SetupMapTopSubMenu(client);
	}
}

void SetupMapTopMenu(int client) {
	gH_MapTopMenu[client] = CreateMenu(MenuHandler_MapTop);
	AddMenuItem(gH_MapTopMenu[client], "", "Top 20");
	AddMenuItem(gH_MapTopMenu[client], "", "Top 20 PRO");
}

public int MenuHandler_MapTop(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:DB_OpenMapTop(param1, gC_MapTopMap[param1]);
			case 1:DB_OpenMapTopPro(param1, gC_MapTopMap[param1]);
		}
	}
}

void SetupMapTopSubMenu(int client) {
	gH_MapTopSubmenu[client] = CreateMenu(MenuHandler_MapTopSubmenu);
}

public int MenuHandler_MapTopSubmenu(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Cancel && param2 == MenuCancel_Exit) {
		OpenMapTopMenu(param1);
	}
}

void OpenMapTopMenu(int client) {
	if (!gB_ConnectedToDB) {
		PrintNoDBMessage(client);
		return;
	}
	SetMenuTitle(gH_MapTopMenu[client], "Map Top - %s", gC_MapTopMap[client]);
	DisplayMenu(gH_MapTopMenu[client], client, MENU_TIME_FOREVER);
} 