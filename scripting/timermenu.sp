/*	timermenu.sp

	Implementation of the teleport menu.
*/

void TimerMenuSetup(int client) {
	gH_TimerMenu[client] = CreateMenu(TimerMenuHandler);
	TimerMenuAddTeleportItems(client);
	SetMenuExitButton(gH_TimerMenu[client], false);
	SetMenuOptionFlags(gH_TimerMenu[client], MENUFLAG_NO_SOUND);
}

void TimerMenuSetupAll() {
	for (int client = 1; client <= MaxClients; client++) {
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
	AddMenuItem(gH_TimerMenu[client], "sm_checkpoint", "Save");
}

void TimerMenuAddItemTeleport(int client) {
	if (gI_CheckpointsSet[client] > 0) {
		AddMenuItem(gH_TimerMenu[client], "sm_gocheck", "Back");
	}
	else {
		AddMenuItem(gH_TimerMenu[client], "sm_gocheck", "Back", ITEMDRAW_DISABLED);
	}
}

void TimerMenuAddItemUndo(int client) {
	if (gI_TeleportsUsed[client] > 0 && gB_CanUndo[client]) {
		AddMenuItem(gH_TimerMenu[client], "sm_undo", "Undo");
	}
	else {
		AddMenuItem(gH_TimerMenu[client], "sm_undo", "Undo", ITEMDRAW_DISABLED);
	}
}

void TimerMenuAddItemStart(int client) {
	AddMenuItem(gH_TimerMenu[client], "sm_start", "Start");
}

void UpdateTimerMenu(int client) {
	// Check if other menu has been closed, and if timer menu should be reopened
	if (gB_UsingOtherMenu[client] && GetClientMenu(client) == MenuSource_None)
	{
		gB_UsingOtherMenu[client] = false;
	}
	
	if (!gB_UsingOtherMenu[client]) {
		if (IsPlayerAlive(client)) {
			UpdateTimerMenuTitle(client);
			// Alive and playing
			if (gB_UsingTeleportMenu[client]) {
				if (gB_UsingTeleportMenu[client]) {
					UpdateTimerMenuItems(client);
					DisplayMenu(gH_TimerMenu[client], client, 1);
				}
			}
			else {
				// Use a panel to just draw the title (since menu doesn't seem to work when there are no items)
				Handle timerPanel = CreatePanel();
				char timerMenuTitle[64];
				GetMenuTitle(gH_TimerMenu[client], timerMenuTitle, sizeof(timerMenuTitle));
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
				GetMenuTitle(gH_TimerMenu[spectatedPlayer], spectatedPlayerMenuTitle, sizeof(spectatedPlayerMenuTitle));
				DrawPanelText(timerPanel, spectatedPlayerMenuTitle);
				SendPanelToClient(timerPanel, client, TimerMenuHandler, 1);
				CloseHandle(timerPanel);
			}
		}
	}
}

void UpdateTimerMenuTitle(int client) {
	if (gB_TimerRunning[client]) {
		SetMenuTitle(gH_TimerMenu[client], "%s %s", GetRunTypeString(client), TimerFormatTime(gF_CurrentTime[client]));
	}
	else {
		SetMenuTitle(gH_TimerMenu[client], "Time Stopped");
	}
}

void UpdateTimerMenuItems(int client) {
	RemoveAllMenuItems(gH_TimerMenu[client]);
	TimerMenuAddTeleportItems(client);
}

public int TimerMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2) {
			case 0:MakeCheckpoint(param1);
			case 1:TeleportToCheckpoint(param1);
			case 2:UndoTeleport(param1);
			case 3:TeleportToStart(param1);
		}
	}
}

// Add command listeners for other menu commands as specified in menu_commands.txt so that the
// plugin can temporarily disable the timer menu while the player is using the other menu.
public void SetupOtherMenuListeners() {
	char menuCommandsPath[] = "cfg/sourcemod/simplekz/exception_list.txt";
	char line[256];
	
	if (FileExists(menuCommandsPath)) {
		Handle fileHandle = OpenFile(menuCommandsPath, "r");
		
		while (!IsEndOfFile(fileHandle) && ReadFileLine(fileHandle, line, sizeof(line)))
		{
			if ((StrContains(line, "//", true) == -1))
			{
				TrimString(line);
				if (!StrEqual(line, ""))
				{
					AddCommandListener(CommandOpenOtherMenu, line);
				}
			}
		}
		
		if (fileHandle != INVALID_HANDLE) {
			CloseHandle(fileHandle);
		}
	}
	else {
		SetFailState("Failed to load file (%s not found).", menuCommandsPath);
	}
} 