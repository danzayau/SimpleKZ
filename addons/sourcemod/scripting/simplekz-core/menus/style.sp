/*
	Style Menu
	
	Lets players pick their movement style.
*/

void StyleMenuCreateMenus()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		StyleMenuCreate(client);
	}
}

void StyleMenuDisplay(int client)
{
	g_StyleMenu[client].SetTitle("%T", "Style Menu - Title", client);
	StyleMenuAddItems(client, g_StyleMenu[client]);
	g_StyleMenu[client].Display(client, MENU_TIME_FOREVER);
}



/*===============================  Public Callbacks  ===============================*/

public int MenuHandler_MovementStyle(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:SetOption(param1, KZOption_Style, KZStyle_Standard);
			case 1:SetOption(param1, KZOption_Style, KZStyle_Legacy);
		}
	}
}



/*===============================  Static Functions  ===============================*/

static void StyleMenuCreate(int client)
{
	g_StyleMenu[client] = new Menu(MenuHandler_MovementStyle);
}

static void StyleMenuAddItems(int client, Menu menu)
{
	char text[32];
	menu.RemoveAllItems();
	int styleCount = view_as<int>(KZStyle);
	for (int style = 0; style < styleCount; style++)
	{
		FormatEx(text, sizeof(text), "%T", gC_StylePhrases[style], client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
} 