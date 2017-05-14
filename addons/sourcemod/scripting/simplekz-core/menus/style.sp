/*
	Style Menu
	
	Lets players pick their movement style.
*/



static Menu styleMenu[MAXPLAYERS + 1];



// =========================  PUBLIC  ========================= //

void CreateMenusStyle()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		styleMenu[client] = new Menu(MenuHandler_MovementStyle);
	}
}

void DisplayStyleMenu(int client)
{
	styleMenu[client].SetTitle("%T", "Style Menu - Title", client);
	StyleMenuAddItems(client, styleMenu[client]);
	styleMenu[client].Display(client, MENU_TIME_FOREVER);
}



// =========================  HANDLER  ========================= //

public int MenuHandler_MovementStyle(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		SetOption(param1, Option_Style, param2);
	}
}



// =========================  PRIVATE  ========================= //

static void StyleMenuAddItems(int client, Menu menu)
{
	char temp[32];
	menu.RemoveAllItems();
	for (int style = 0; style < STYLE_COUNT; style++)
	{
		FormatEx(temp, sizeof(temp), "%T", gC_StylePhrases[style], client);
		menu.AddItem("", temp, ITEMDRAW_DEFAULT);
	}
} 