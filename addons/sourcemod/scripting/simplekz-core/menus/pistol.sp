/*    
    Pistol Menu
    
    Lets players pick and be given a pistol.
*/

void CreatePistolMenuAll()
{
	for (int client = 1; client <= MaxClients; client++) {
		CreatePistolMenu(client);
	}
}

static void CreatePistolMenu(int client)
{
	g_PistolMenu[client] = new Menu(MenuHandler_Pistol);
}

public int MenuHandler_Pistol(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		g_Pistol[param1] = view_as<KZPistol>(param2);
		GivePlayerPistol(param1, view_as<KZPistol>(param2));
		DisplayPistolMenu(param1);
	}
	else if (action == MenuAction_Cancel && gB_CameFromOptionsMenu[param1])
	{
		gB_CameFromOptionsMenu[param1] = false;
		DisplayOptionsMenu(param1);
	}
}

void DisplayPistolMenu(int client)
{
	UpdatePistolMenu(client, g_PistolMenu[client]);
	g_PistolMenu[client].Display(client, MENU_TIME_FOREVER);
}

static void UpdatePistolMenu(int client, Menu menu)
{
	menu.SetTitle("%T", "Pistol Menu - Title", client);
	menu.RemoveAllItems();
	for (int pistol = 0; pistol < sizeof(gC_Pistols); pistol++) {
		menu.AddItem("", gC_Pistols[pistol][1]);
	}
} 