/*	menus.sp
	
	Menus for the SimpleKZ ranking system.
*/


void CreateMenus() {
	CreateMapTopMenuAll();
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
	DisplayMenu(gH_MapTopMenu[client], client, MENU_TIME_FOREVER);
}

void UpdateMapTopMenu(int client) {
	char text[32];
	RemoveAllMenuItems(gH_MapTopMenu[client]);
	FormatEx(text, sizeof(text), "%T", "MapTopMenu_Top20", client);
	AddMenuItem(gH_MapTopMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "MapTopMenu_Top20Pro", client);
	AddMenuItem(gH_MapTopMenu[client], "", text);
}

public int MenuHandler_MapTop(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:DB_OpenTop20(param1, gC_MapTopMap[param1]);
			case 1:DB_OpenTop20Pro(param1, gC_MapTopMap[param1]);
		}
	}
}

void CreateMapTopSubMenu(int client) {
	gH_MapTopSubmenu[client] = CreateMenu(MenuHandler_MapTopSubmenu);
}

public int MenuHandler_MapTopSubmenu(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Cancel && param2 == MenuCancel_Exit) {
		DisplayMapTopMenu(param1);
	}
} 