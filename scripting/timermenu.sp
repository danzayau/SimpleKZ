/*	timermenu.sp

*/


// Functions

void TimerMenuSetup(int client) {
	g_timerMenu[client] = CreateMenu(TimerMenuHandler);
	TimerMenuAddTeleportItems(client);
	SetMenuExitButton(g_timerMenu[client], false);
	SetMenuOptionFlags(g_timerMenu[client], MENUFLAG_NO_SOUND);
}

void TimerMenuSetupAll() {
	for (int client = 0; client < MAXPLAYERS + 1; client++) {
		TimerMenuSetup(client);
	}
}

void TimerMenuAddTeleportItems(int client) {
	TimerMenuAddItemCheckpoint(client);
	TimerMenuAddItemTeleport(client);
	TimerMenuAddItemUndo(client);
	TimerMenuAddItemStart(client);
}

void TimerMenuAddItemCheckpoint(int client) {
	AddMenuItem(g_timerMenu[client], "sm_checkpoint", "Save");
}

void TimerMenuAddItemTeleport(int client) {
	if (g_clientCheckpointsSet[client] > 0) {
		AddMenuItem(g_timerMenu[client], "sm_gocheck", "Back");
	}
	else {
		AddMenuItem(g_timerMenu[client], "sm_gocheck", "Back", ITEMDRAW_DISABLED);
	}
}

void TimerMenuAddItemUndo(int client) {
	if (g_clientTeleportsUsed[client] > 0) {
		AddMenuItem(g_timerMenu[client], "sm_undo", "Undo");
	}
	else {
		AddMenuItem(g_timerMenu[client], "sm_undo", "Undo", ITEMDRAW_DISABLED);
	}
}

void TimerMenuAddItemStart(int client) {
	AddMenuItem(g_timerMenu[client], "sm_start", "Start");
}

void TimerResetClientMenuVars(int client) {
	g_clientUsingTeleportMenu[client] = true;
	g_timerMenu[client] = null;
}

void UpdateTimerMenu(int client) {
	// Check if other menu has been closed, and if timer menu should be reopened
	if (g_clientUsingOtherMenu[client] && GetClientMenu(client) == MenuSource_None)
	{
		g_clientUsingOtherMenu[client] = false;
		g_clientWasUsingTeleportMenu[client] = false;
	}
	if (!g_clientUsingOtherMenu[client] && g_clientWasUsingTeleportMenu[client]) {
		g_clientUsingTeleportMenu[client] = true;
	}
	
	
	if (IsPlayerAlive(client)) {
		UpdateTimerMenuTitle(client);
		// Alive and playing
		if (g_clientUsingTeleportMenu[client]) {
			if (g_clientUsingTeleportMenu[client]) {
				UpdateTimerMenuItems(client);
				DisplayMenu(g_timerMenu[client], client, 1);
			}
		}
		else {
			// Use a panel to just draw the title (since menu doesn't seem to work when there are no items)
			Handle timerPanel = CreatePanel();
			char timerMenuTitle[64];
			GetMenuTitle(g_timerMenu[client], timerMenuTitle, sizeof(timerMenuTitle))
			DrawPanelText(timerPanel, timerMenuTitle);
			SendPanelToClient(timerPanel, client, TimerMenuHandler, 1);
			CloseHandle(timerPanel);
		}
	}
	// Spectating
	else {
		int spectatedPlayer = GetSpectatedPlayer(client);
		if (IsValidClient(spectatedPlayer)) {
			// Use a panel to just draw the title (since menu doesn't seem to work when there are no items)
			Handle timerPanel = CreatePanel();
			char spectatedPlayerMenuTitle[64];
			GetMenuTitle(g_timerMenu[spectatedPlayer], spectatedPlayerMenuTitle, sizeof(spectatedPlayerMenuTitle));
			DrawPanelText(timerPanel, spectatedPlayerMenuTitle);
			SendPanelToClient(timerPanel, client, TimerMenuHandler, 1);
			CloseHandle(timerPanel);
		}
	}
}

void UpdateTimerMenuTitle(int client) {
	if (g_clientTimerRunning[client]) {
		SetMenuTitle(g_timerMenu[client], "%s %s", GetRunTypeString(client), TimerFormatTime(g_clientCurrentTime[client]));
	}
	else {
		SetMenuTitle(g_timerMenu[client], "Time Stopped");
	}
}

void UpdateTimerMenuItems(int client) {
	RemoveAllMenuItems(g_timerMenu[client]);
	TimerMenuAddTeleportItems(client);
}

public int TimerMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2) {
			case 0:MakeCheckpoint(param1);
			case 1:TeleportToCheckpoint(param1)
			case 2:UndoTeleport(param1)
			case 3:TeleportToStart(param1)
		}
	}
}

void TimerMenuOpenOtherMenu(client) {
	g_clientUsingOtherMenu[client] = true;
	if (g_clientUsingTeleportMenu[client]) {
		g_clientUsingTeleportMenu[client] = false;
		g_clientWasUsingTeleportMenu[client] = true;
	}
	else {
		g_clientWasUsingTeleportMenu[client] = false;
	}
} 