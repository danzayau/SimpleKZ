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
	if (gI_MapTopCourse[client] == 0) {
		SetMenuTitle(gH_MapTopMenu[client], "%T", "Map Top Menu - Title", client, 
			gC_MapTopMapName[client], gC_StylePhrases[g_MapTopStyle[client]]);
	}
	else {
		SetMenuTitle(gH_MapTopMenu[client], "%T", "Map Top Menu - Title (Bonus)", client, 
			gC_MapTopMapName[client], gI_MapTopCourse[client], gC_StylePhrases[g_MapTopStyle[client]]);
	}
	AddItemsMapTopMenu(client);
	DisplayMenu(gH_MapTopMenu[client], client, MENU_TIME_FOREVER);
}

void AddItemsMapTopMenu(int client) {
	char text[32];
	RemoveAllMenuItems(gH_MapTopMenu[client]);
	for (int timeType = 0; timeType < view_as<int>(KZTimeType); timeType++) {
		FormatEx(text, sizeof(text), "%T", "Map Top Menu - Top 20", client, gC_TimeTypePhrases[timeType]);
		AddMenuItem(gH_MapTopMenu[client], "", text);
	}
}

public int MenuHandler_MapTop(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		DB_OpenMapTop20(param1, gI_MapTopMapID[param1], gI_MapTopCourse[param1], g_MapTopStyle[param1], view_as<KZTimeType>(param2));
	}
}

void CreateMapTopSubMenu(int client) {
	gH_MapTopSubMenu[client] = CreateMenu(MenuHandler_MapTopSubmenu);
	SetMenuPagination(gH_MapTopSubMenu[client], 5);
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
}

public int MenuHandler_PlayerTop(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		DB_OpenPlayerTop20(param1, view_as<KZTimeType>(param2), g_PlayerTopStyle[param1]);
	}
}

void AddItemsPlayerTopMenu(int client) {
	char text[32];
	RemoveAllMenuItems(gH_PlayerTopMenu[client]);
	for (int timeType = 0; timeType < view_as<int>(KZTimeType); timeType++) {
		FormatEx(text, sizeof(text), "%T", "Player Top Menu - Top 20", client, gC_TimeTypePhrases[timeType]);
		AddMenuItem(gH_PlayerTopMenu[client], "", text);
	}
}

void DisplayPlayerTopMenu(int client) {
	SetMenuTitle(gH_PlayerTopMenu[client], "%T", "Player Top Menu - Title", client, gC_StylePhrases[g_PlayerTopStyle[client]]);
	AddItemsPlayerTopMenu(client);
	DisplayMenu(gH_PlayerTopMenu[client], client, MENU_TIME_FOREVER);
}

void CreatePlayerTopSubMenu(int client) {
	gH_PlayerTopSubMenu[client] = CreateMenu(MenuHandler_PlayerTopSubmenu);
	SetMenuPagination(gH_PlayerTopSubMenu[client], 5);
}

public int MenuHandler_PlayerTopSubmenu(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Cancel && param2 == MenuCancel_Exit) {
		DisplayPlayerTopMenu(param1);
	}
} 