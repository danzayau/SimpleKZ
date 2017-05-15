/*
	Options
	
	Player options to customise their experience.
*/



static int options[OPTION_COUNT][MAXPLAYERS + 1];

static int optionCounts[OPTION_COUNT] = 
{
	STYLE_COUNT, 
	SHOWINGTPMENU_COUNT, 
	SHOWINGINFOPANEL_COUNT, 
	SHOWINGKEYS_COUNT, 
	SHOWINGPLAYERS_COUNT, 
	SHOWINGWEAPON_COUNT, 
	AUTORESTART_COUNT, 
	SLAYONEND_COUNT, 
	PISTOL_COUNT, 
	CHECKPOINTMESSAGES_COUNT, 
	CHECKPOINTSOUNDS_COUNT, 
	TELEPORTSOUNDS_COUNT, 
	ERRORSOUNDS_COUNT, 
	TIMERTEXT_COUNT, 
	SPEEDTEXT_COUNT
};



// =========================  PUBLIC  ========================= //

int GetOption(int client, Option option)
{
	return options[option][client];
}

void SetOption(int client, Option option, int optionValue, bool printMessage = false)
{
	if (GetOption(client, option) != optionValue)
	{
		options[option][client] = optionValue;
		if (printMessage)
		{
			PrintOptionChangeMessage(client, option);
		}
		
		Call_SKZ_OnOptionChanged(client, option, optionValue);
	}
}

void CycleOption(int client, Option option, bool printMessage = false)
{
	SetOption(client, option, (GetOption(client, option) + 1) % optionCounts[option], printMessage);
}



// =========================  LISTENERS  ========================= //

void SetupClientOptions(int client)
{
	SetDefaultOptions(client);
}



// =========================  PRIVATE  ========================= //

static void SetDefaultOptions(int client)
{
	SetOption(client, Option_Style, GetConVarInt(gCV_DefaultStyle));
	SetOption(client, Option_ShowingTPMenu, ShowingTPMenu_Enabled);
	SetOption(client, Option_ShowingInfoPanel, ShowingInfoPanel_Enabled);
	SetOption(client, Option_ShowingKeys, ShowingKeys_Spectating);
	SetOption(client, Option_ShowingPlayers, ShowingPlayers_Enabled);
	SetOption(client, Option_ShowingWeapon, ShowingWeapon_Enabled);
	SetOption(client, Option_AutoRestart, AutoRestart_Enabled);
	SetOption(client, Option_SlayOnEnd, SlayOnEnd_Enabled);
	SetOption(client, Option_Pistol, Pistol_USP);
	SetOption(client, Option_CheckpointMessages, CheckpointMessages_Disabled);
	SetOption(client, Option_CheckpointSounds, CheckpointSounds_Enabled);
	SetOption(client, Option_TeleportSounds, TeleportSounds_Disabled);
	SetOption(client, Option_ErrorSounds, ErrorSounds_Enabled);
	SetOption(client, Option_TimerText, TimerText_InfoPanel);
	SetOption(client, Option_SpeedText, SpeedText_InfoPanel);
}

static void PrintOptionChangeMessage(int client, Option option) {
	if (!IsValidClient(client))
	{
		return;
	}
	
	// NOTE: Not all options have a message for when they are changed.
	switch (option)
	{
		case Option_Style:
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "Switched Style", gC_StylePhrases[GetOption(client, Option_Style)]);
		}
		case Option_ShowingTPMenu:
		{
			switch (GetOption(client, option))
			{
				case ShowingTPMenu_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Disable");
				}
				case ShowingTPMenu_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Enable");
				}
			}
		}
		case Option_ShowingInfoPanel:
		{
			switch (GetOption(client, option))
			{
				case ShowingInfoPanel_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Disable");
				}
				case ShowingInfoPanel_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Enable");
				}
			}
		}
		case Option_ShowingPlayers:
		{
			switch (GetOption(client, option))
			{
				case ShowingPlayers_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Disable");
				}
				case ShowingPlayers_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Enable");
				}
			}
		}
		case Option_ShowingWeapon:
		{
			switch (GetOption(client, option))
			{
				case ShowingWeapon_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Weapon - Disable");
				}
				case ShowingWeapon_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Weapon - Enable");
				}
			}
		}
		case Option_AutoRestart:
		{
			switch (GetOption(client, option))
			{
				case AutoRestart_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Disable");
				}
				case AutoRestart_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Enable");
				}
			}
		}
		case Option_SlayOnEnd:
		{
			switch (GetOption(client, option))
			{
				case SlayOnEnd_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Disable");
				}
				case SlayOnEnd_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Enable");
				}
			}
		}
	}
} 