/*	menus.sp
	
	Menus for the SimpleKZ ranking system.
*/


void CreateMenus() {
	CreateMapTopMenuAll();
	CreatePlayerTopMenuAll();
}



/*===============================  MapTop Menu ===============================*/

void CreateMapTopMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateMapTopMenu(client);
		CreateMapTopSubMenu(client);
	}
}

void CreateMapTopMenu(int client) {
	gH_MapTopMenu[client] = CreateMenu(MenuHandler_MapTop);
}

void DisplayMapTopMenu(int client) {
	SetMenuTitle(gH_MapTopMenu[client], "%T", "MapTopMenu_Title", client, gC_MapTopMap[client]);
	AddItemsMapTopMenu(client);
	DisplayMenu(gH_MapTopMenu[client], client, MENU_TIME_FOREVER);
}

void AddItemsMapTopMenu(int client) {
	char text[32];
	RemoveAllMenuItems(gH_MapTopMenu[client]);
	FormatEx(text, sizeof(text), "%T", "MapTopMenu_Top20", client);
	AddMenuItem(gH_MapTopMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "MapTopMenu_Top20Pro", client);
	AddMenuItem(gH_MapTopMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "MapTopMenu_Top20Theoretical", client);
	AddMenuItem(gH_MapTopMenu[client], "", text);
}

public int MenuHandler_MapTop(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:DB_OpenMapTop20(param1, gC_MapTopMap[param1], RunType_Normal);
			case 1:DB_OpenMapTop20(param1, gC_MapTopMap[param1], RunType_Pro);
			case 2:DB_OpenMapTop20(param1, gC_MapTopMap[param1], RunType_Theoretical);
		}
	}
}

void CreateMapTopSubMenu(int client) {
	gH_MapTopSubMenu[client] = CreateMenu(MenuHandler_MapTopSubmenu);
}

public int MenuHandler_MapTopSubmenu(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Cancel && param2 == MenuCancel_Exit) {
		DisplayMapTopMenu(param1);
	}
}



/*===============================  Top Menu ===============================*/

void CreatePlayerTopMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreatePlayerTopMenu(client);
		CreatePlayerTopSubMenu(client);
	}
}

void CreatePlayerTopMenu(int client) {
	gH_PlayerTopMenu[client] = CreateMenu(MenuHandler_PlayerTop);
	SetMenuTitle(gH_PlayerTopMenu[client], "%T", "PlayerTopMenu_Title", client);
}

public int MenuHandler_PlayerTop(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:DB_PlayerTop20(param1, RunType_Normal);
			case 1:DB_PlayerTop20(param1, RunType_Pro);
		}
	}
}

void AddItemsPlayerTopMenu(int client) {
	char text[32];
	RemoveAllMenuItems(gH_PlayerTopMenu[client]);
	FormatEx(text, sizeof(text), "%T", "PlayerTopMenu_Top20", client);
	AddMenuItem(gH_PlayerTopMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "PlayerTopMenu_Top20Pro", client);
	AddMenuItem(gH_PlayerTopMenu[client], "", text);
}

void DisplayPlayerTopMenu(int client) {
	DisplayMenu(gH_PlayerTopMenu[client], client, MENU_TIME_FOREVER);
}

void CreatePlayerTopSubMenu(int client) {
	gH_PlayerTopSubMenu[client] = CreateMenu(MenuHandler_PlayerTopSubmenu);
}

public int MenuHandler_PlayerTopSubmenu(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Cancel && param2 == MenuCancel_Exit) {
		DisplayPlayerTopMenu(param1);
	}
} 