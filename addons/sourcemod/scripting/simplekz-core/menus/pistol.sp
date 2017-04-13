/*
	Pistol Menu
	
	Lets players pick and be given a pistol.
*/

void PistolMenuCreateMenus()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		PistolMenuCreate(client);
	}
}

void PistolMenuDisplay(int client, int atItem = 0)
{
	PistolMenuUpdate(client, g_PistolMenu[client]);
	g_PistolMenu[client].DisplayAt(client, atItem, MENU_TIME_FOREVER);
}



/*===============================  Public Callbacks  ===============================*/

public int MenuHandler_Pistol(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		g_Pistol[param1] = view_as<KZPistol>(param2);
		PistolUpdate(param1);
		PistolMenuDisplay(param1); // Re-open
	}
	else if (action == MenuAction_Cancel && gB_CameFromOptionsMenu[param1])
	{
		gB_CameFromOptionsMenu[param1] = false;
		OptionsMenuDisplay(param1);
	}
}



/*===============================  Static Functions  ===============================*/

static void PistolMenuCreate(int client)
{
	g_PistolMenu[client] = new Menu(MenuHandler_Pistol);
}

static void PistolMenuUpdate(int client, Menu menu)
{
	menu.SetTitle("%T", "Pistol Menu - Title", client);
	menu.RemoveAllItems();
	
	int numberOfPistols = sizeof(gC_Pistols);
	for (int pistol = 0; pistol < numberOfPistols; pistol++) {
		menu.AddItem("", gC_Pistols[pistol][1]);
	}
} 