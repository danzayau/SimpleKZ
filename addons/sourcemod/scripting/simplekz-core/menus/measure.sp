/*
	Measure Menu
	
	Lets players measure the distance between two points.
	
	Credits to DaFox (https://forums.alliedmods.net/showthread.php?t=88830?t=88830)
*/

void MeasureMenuCreateMenus()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		MeasureMenuCreate(client);
	}
}

void MeasureMenuDisplay(int client)
{
	MeasureResetPos(client);
	MeasureMenuUpdate(client, gH_MeasureMenu[client]);
	gH_MeasureMenu[client].Display(client, MENU_TIME_FOREVER);
}



/*===============================  Public Callbacks  ===============================*/

public int MenuHandler_Measure(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: //Point A (Green)
			{
				MeasureGetPos(param1, 0);
			}
			case 1: //Point B (Red)
			{
				MeasureGetPos(param1, 1);
			}
			case 2:
			{  //Find Distance
				if (gB_MeasurePosSet[param1][0] && gB_MeasurePosSet[param1][1])
				{
					float vDist = GetVectorDistance(gF_MeasurePos[param1][0], gF_MeasurePos[param1][1]);
					float vHightDist = (gF_MeasurePos[param1][1][2] - gF_MeasurePos[param1][0][2]);
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Result", vDist, vHightDist);
					MeasureBeam(param1, gF_MeasurePos[param1][0], gF_MeasurePos[param1][1], 5.0, 2.0, 200, 200, 200);
				}
				else
				{
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Failure (Points Not Set)");
				}
			}
		}
		DisplayMenu(gH_MeasureMenu[param1], param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel)
	{
		MeasureResetPos(param1);
	}
}



/*===============================  Static Functions  ===============================*/

static void MeasureMenuCreate(int client)
{
	gH_MeasureMenu[client] = new Menu(MenuHandler_Measure);
}

static void MeasureMenuUpdate(int client, Menu menu)
{
	menu.SetTitle("%T", "Measure Menu - Title", client);
	
	char text[32];
	menu.RemoveAllItems();
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point A", client);
	menu.AddItem("", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point B", client);
	menu.AddItem("", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Get Distance", client);
	menu.AddItem("", text);
} 