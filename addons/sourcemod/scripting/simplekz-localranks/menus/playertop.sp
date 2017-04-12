/*
	Player Top Menu
	
	Lets players view the top record holders
	See also:
		database/open_playertop20.sp
*/

void CreatePlayerTopMenuAll()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		CreatePlayerTopMenu(client);
		CreatePlayerTopSubMenu(client);
	}
}

void DisplayPlayerTopMenu(int client)
{
	gH_PlayerTopMenu[client].SetTitle("%T", "Player Top Menu - Title", client, gC_StylePhrases[g_PlayerTopStyle[client]]);
	AddItemsPlayerTopMenu(client, gH_PlayerTopMenu[client]);
	gH_PlayerTopMenu[client].Display(client, MENU_TIME_FOREVER);
}



/*===============================  Public Callbacks  ===============================*/

public int MenuHandler_PlayerTop(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		DB_OpenPlayerTop20(param1, view_as<KZTimeType>(param2), g_PlayerTopStyle[param1]);
	}
}

public int MenuHandler_PlayerTopSubmenu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Cancel && param2 == MenuCancel_Exit) {
		DisplayPlayerTopMenu(param1);
	}
}



/*===============================  Static Functions  ===============================*/

static void CreatePlayerTopMenu(int client)
{
	gH_PlayerTopMenu[client] = new Menu(MenuHandler_PlayerTop);
}

static void CreatePlayerTopSubMenu(int client)
{
	gH_PlayerTopSubMenu[client] = new Menu(MenuHandler_PlayerTopSubmenu);
	gH_PlayerTopSubMenu[client].Pagination = 5;
}

static void AddItemsPlayerTopMenu(int client, Menu menu)
{
	char text[32];
	menu.RemoveAllItems();
	for (int timeType = 0; timeType < view_as<int>(KZTimeType); timeType++)
	{
		FormatEx(text, sizeof(text), "%T", "Player Top Menu - Top 20", client, gC_TimeTypePhrases[timeType]);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
} 