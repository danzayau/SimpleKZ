/*
	Teleport Menu
	
	Lets players easily use teleport functionality.
*/

void TPMenuCreateMenus()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		CreateTPMenu(client);
	}
}

void TPMenuUpdate(int client)
{
	if (gB_TPMenuIsShowing[client])
	{
		CancelClientMenu(client);
		gB_TPMenuIsShowing[client] = false;
	}
}

// Re-opens the TP menu if it's been closed.
void TPMenuDisplay(int client)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	// Checks that no other menu is open instead of rudely interrupting it
	if (GetClientMenu(client) == MenuSource_None
		 && g_ShowingTPMenu[client] == KZShowingTPMenu_Enabled
		 && !gB_TPMenuIsShowing[client] && IsPlayerAlive(client))
	{
		TPMenuUpdateItems(client, g_TPMenu[client]);
		g_TPMenu[client].Display(client, MENU_TIME_FOREVER);
		gB_TPMenuIsShowing[client] = true;
	}
}



/*===============================  Public Callbacks  ===============================*/

public int MenuHandler_TPMenu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:MakeCheckpoint(param1);
			case 1:TeleportToCheckpoint(param1);
			case 2:TogglePause(param1);
			case 3:TeleportToStart(param1);
			case 4:UndoTeleport(param1);
		}
		gB_TPMenuIsShowing[param1] = false;
	}
	else if (action == MenuAction_Cancel)
	{
		gB_TPMenuIsShowing[param1] = false;
	}
}



/*===============================  Static Functions  ===============================*/

static void CreateTPMenu(int client)
{
	g_TPMenu[client] = new Menu(MenuHandler_TPMenu);
	g_TPMenu[client].OptionFlags = MENUFLAG_NO_SOUND;
	g_TPMenu[client].ExitButton = false;
}

static void TPMenuUpdateItems(int client, Menu menu)
{
	menu.RemoveAllItems();
	AddItemsTPMenu(client, menu);
}

static void AddItemsTPMenu(int client, Menu menu)
{
	AddItemTPMenuCheckpoint(client, menu);
	AddItemTPMenuTeleport(client, menu);
	AddItemTPMenuPause(client, menu);
	AddItemTPMenuStart(client, menu);
	AddItemTPMenuUndo(client, menu);
}

static void AddItemTPMenuCheckpoint(int client, Menu menu)
{
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Checkpoint", client);
	menu.AddItem("", text, ITEMDRAW_DEFAULT);
}

static void AddItemTPMenuTeleport(int client, Menu menu)
{
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Teleport", client);
	if (gI_CheckpointCount[client] > 0)
	{
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else
	{
		menu.AddItem("", text, ITEMDRAW_DISABLED);
	}
}

static void AddItemTPMenuUndo(int client, Menu menu)
{
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Undo TP", client);
	if (gI_TeleportsUsed[client] > 0 && gB_LastTeleportOnGround[client] || gB_LastTeleportInBhopTrigger[client])
	{
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else
	{
		menu.AddItem("", text, ITEMDRAW_DISABLED);
	}
}

static void AddItemTPMenuPause(int client, Menu menu)
{
	char text[16];
	if (!gB_Paused[client])
	{
		FormatEx(text, sizeof(text), "%T", "TP Menu - Pause", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else
	{
		FormatEx(text, sizeof(text), "%T", "TP Menu - Resume", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
}

static void AddItemTPMenuStart(int client, Menu menu) {
	char text[16];
	if (gB_HasStartedThisMap[client])
	{
		FormatEx(text, sizeof(text), "%T", "TP Menu - Restart", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else
	{
		FormatEx(text, sizeof(text), "%T", "TP Menu - Respawn", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
} 