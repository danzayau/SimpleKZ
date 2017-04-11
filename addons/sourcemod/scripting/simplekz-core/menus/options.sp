/*    
    Pistol Menu
    
    Lets players view and set options.
*/

void CreateOptionsMenuAll()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		CreateOptionsMenu(client);
	}
}

static void CreateOptionsMenu(int client)
{
	g_OptionsMenu[client] = new Menu(MenuHandler_Options);
	g_OptionsMenu[client].Pagination = 6;
}

public int MenuHandler_Options(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:IncrementOption(param1, KZOption_ShowingTPMenu);
			case 1:IncrementOption(param1, KZOption_ShowingInfoPanel);
			case 2:IncrementOption(param1, KZOption_ShowingPlayers);
			case 3:IncrementOption(param1, KZOption_ShowingWeapon);
			case 4:IncrementOption(param1, KZOption_AutoRestart);
			case 5:
			{
				gB_CameFromOptionsMenu[param1] = true;
				DisplayPistolMenu(param1);
			}
			case 6:IncrementOption(param1, KZOption_SlayOnEnd);
			case 7:IncrementOption(param1, KZOption_ShowingKeys);
			case 8:IncrementOption(param1, KZOption_CheckpointMessages);
			case 9:IncrementOption(param1, KZOption_CheckpointSounds);
			case 10:IncrementOption(param1, KZOption_TeleportSounds);
			case 11:IncrementOption(param1, KZOption_TimerText);
		}
		if (param2 != 5)
		{
			// Reopen the menu at the same place
			DisplayOptionsMenu(param1, param2 / 6 * 6); // Round item number down to multiple of 6
		}
	}
}

void DisplayOptionsMenu(int client, int atItem = 0)
{
	UpdateOptionsMenu(client, g_OptionsMenu[client]);
	g_OptionsMenu[client].DisplayAt(client, atItem, MENU_TIME_FOREVER);
}

static void UpdateOptionsMenu(int client, Menu menu)
{
	menu.SetTitle("%T", "Options Menu - Title", client);
	menu.RemoveAllItems();
	OptionsAddToggle(client, menu, g_ShowingTPMenu[client], "Options Menu - Teleport Menu");
	OptionsAddToggle(client, menu, g_ShowingInfoPanel[client], "Options Menu - Info Panel");
	OptionsAddToggle(client, menu, g_ShowingPlayers[client], "Options Menu - Show Players");
	OptionsAddToggle(client, menu, g_ShowingWeapon[client], "Options Menu - Show Weapon");
	OptionsAddToggle(client, menu, g_AutoRestart[client], "Options Menu - Auto Restart");
	OptionsAddPistol(client, menu);
	OptionsAddToggle(client, menu, g_SlayOnEnd[client], "Options Menu - Slay On End");
	OptionsAddToggle(client, menu, g_ShowingKeys[client], "Options Menu - Show Keys");
	OptionsAddToggle(client, menu, g_CheckpointMessages[client], "Options Menu - Checkpoint Messages");
	OptionsAddToggle(client, menu, g_CheckpointSounds[client], "Options Menu - Checkpoint Sounds");
	OptionsAddToggle(client, menu, g_TeleportSounds[client], "Options Menu - Teleport Sounds");
	OptionsAddTimerText(client, menu);
}

static void OptionsAddToggle(int client, Menu menu, any optionValue, const char[] optionPhrase)
{
	char text[32];
	if (view_as<int>(optionValue) == 0)
	{
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Disabled", client);
	}
	else
	{
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Enabled", client);
	}
	
	menu.AddItem("", text);
}

static void OptionsAddPistol(int client, Menu menu)
{
	char text[32];
	FormatEx(text, sizeof(text), "%T - %s", "Options Menu - Pistol", client, gC_Pistols[g_Pistol[client]][1]);
	menu.AddItem("", text);
}

static void OptionsAddTimerText(int client, Menu menu)
{
	char text[32];
	FormatEx(text, sizeof(text), "%T - %T", "Options Menu - Timer Text", client, gC_TimerTextOptionPhrases[g_TimerText[client]], client);
	menu.AddItem("", text);
} 