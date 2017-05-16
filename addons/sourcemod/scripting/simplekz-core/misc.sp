/*
	Miscellaneous
	
	Small features that aren't worth splitting into their own file.
*/



// =========================  KZ.CFG  ========================= //

void OnMapStart_KZConfig()
{
	char kzConfigPath[] = "sourcemod/simplekz/kz.cfg";
	char kzConfigPathFull[64];
	FormatEx(kzConfigPathFull, sizeof(kzConfigPathFull), "cfg/%s", kzConfigPath);
	
	if (FileExists(kzConfigPathFull))
	{
		ServerCommand("exec %s", kzConfigPath);
	}
	else
	{
		SetFailState("Failed to load config (cfg/%s not found).", kzConfigPath);
	}
}

// =========================  PLUGIN END  ========================= //

void RestoreDefaults()
{
	gCV_StyleCVar[StyleCVar_Accelerate].RestoreDefault();
	gCV_StyleCVar[StyleCVar_Friction].RestoreDefault();
	gCV_StyleCVar[StyleCVar_AirAccelerate].RestoreDefault();
	gCV_StyleCVar[StyleCVar_LadderScaleSpeed].RestoreDefault();
	gCV_StyleCVar[StyleCVar_MaxVelocity].RestoreDefault();
	gCV_StyleCVar[StyleCVar_Gravity].RestoreDefault();
	gCV_StyleCVar[StyleCVar_EnableBunnyhopping].RestoreDefault();
	gCV_StyleCVar[StyleCVar_AutoBunnyhopping].RestoreDefault();
	gCV_StyleCVar[StyleCVar_StaminaMax].RestoreDefault();
	gCV_StyleCVar[StyleCVar_StaminaLandCost].RestoreDefault();
	gCV_StyleCVar[StyleCVar_StaminaJumpCost].RestoreDefault();
	gCV_StyleCVar[StyleCVar_StaminaRecoveryRate].RestoreDefault();
	gCV_StyleCVar[StyleCVar_MaxSpeed].RestoreDefault();
	gCV_StyleCVar[StyleCVar_WaterAccelerate].RestoreDefault();
	gCV_StyleCVar[StyleCVar_TimeBetweenDucks].RestoreDefault();
	gCV_StyleCVar[StyleCVar_AccelerateUseWeaponSpeed].RestoreDefault();
}

void RemoveHooks()
{
	gCV_PlayerModelAlpha.RemoveChangeHook(OnConVarChanged_PlayerModelAlpha);
	UnhookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	UnhookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	UnhookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	UnhookEvent("round_start", OnRoundStart, EventHookMode_Pre);
	UnhookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	UnhookEntityOutput("trigger_multiple", "OnStartTouch", OnTrigMultTouch);
	RemoveNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
}

// =========================  GODMODE  ========================= //

void UpdateGodMode(int client)
{
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
}



// =========================  NOCLIP  ========================= //

void ToggleNoclip(int client)
{
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	if (Movement_GetMoveType(client) != MOVETYPE_NOCLIP)
	{
		Movement_SetMoveType(client, MOVETYPE_NOCLIP);
	}
	else
	{
		Movement_SetMoveType(client, MOVETYPE_WALK);
	}
}



// =========================  PLAYER COLLISION  ========================= //

void UpdatePlayerCollision(int client)
{
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
}



// =========================  HIDE PLAYERS  ========================= //

void SetupClientHidePlayers(int client)
{
	SDKHook(client, SDKHook_SetTransmit, OnSetTransmitClient);
}

public Action OnSetTransmitClient(int entity, int client)
{
	if (GetOption(client, Option_ShowingPlayers) == ShowingPlayers_Disabled
		 && entity != client
		 && (!IsSpectatingSomeone(client) || entity != GetObserverTarget(client)))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}



// =========================  HIDE WEAPON  ========================= //

void UpdateHideWeapon(int client)
{
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 
		GetOption(client, Option_ShowingWeapon) == ShowingWeapon_Enabled);
}

void OnOptionChanged_HideWeapon(int client, Option option)
{
	if (option == Option_ShowingWeapon)
	{
		UpdateHideWeapon(client);
	}
}



// =========================  CONNECTION MESSAGES  ========================= //

void PrintConnectMessage(int client)
{
	if (!gCV_ConnectionMessages.BoolValue || IsFakeClient(client))
	{
		return;
	}
	
	SKZ_PrintToChatAll(false, "%t", "Client Connection Message", client, client);
}

void PrintDisconnectMessage(int client, Event event) // Hooked to player_disconnect event
{
	if (!gCV_ConnectionMessages.BoolValue)
	{
		return;
	}
	
	SetEventBroadcast(event, true);
	
	if (IsFakeClient(client))
	{
		return;
	}
	
	char reason[64];
	event.GetString("reason", reason, sizeof(reason));
	SKZ_PrintToChatAll(false, "%t", "Client Disconnection Message", client, client, reason);
}



// =========================  FORCE SV_FULL_ALLTALK 1  ========================= //

void OnRoundStart_ForceAllTalk()
{
	gCV_FullAlltalk.SetInt(1);
}



// =========================  SLAY ON END  ========================= //

void OnTimerEnd_SlayOnEnd(int client)
{
	if (GetOption(client, Option_SlayOnEnd) == SlayOnEnd_Enabled)
	{
		CreateTimer(3.0, Timer_SlayPlayer, GetClientUserId(client));
	}
}

public Action Timer_SlayPlayer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (client != 0 && IsPlayerAlive(client))
	{
		ForcePlayerSuicide(client);
	}
	return Plugin_Continue;
}



// =========================  ERROR MESSAGES AND SOUNDS  ========================= //

#define SOUND_ERROR "buttons/button10.wav"

void PlayErrorSound(int client)
{
	if (GetOption(client, Option_ErrorSounds) == ErrorSounds_Enabled)
	{
		EmitSoundToClient(client, SOUND_ERROR);
	}
}



// =========================  STOP SOUNDS  ========================= //

void StopSounds(int client)
{
	ClientCommand(client, "snd_playsounds Music.StopAllExceptMusic");
	SKZ_PrintToChat(client, true, "%t", "Stopped Sounds");
}

Action OnNormalSound_StopSounds(int entity)
{
	char className[20];
	GetEntityClassname(entity, className, sizeof(className));
	if (StrEqual(className, "func_button", false))
	{
		return Plugin_Handled; // No sounds directly from func_button
	}
	return Plugin_Continue;
}



// =========================  PLAYER MODELS  ========================= //

static char playerModelT[256];
static char playerModelCT[256];

void UpdatePlayerModel(int client)
{
	switch (GetClientTeam(client))
	{
		case CS_TEAM_T:SetEntityModel(client, playerModelT);
		case CS_TEAM_CT:SetEntityModel(client, playerModelCT);
	}
	
	UpdatePlayerModelAlpha(client);
}

void UpdatePlayerModelAlpha(int client)
{
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, _, _, _, gCV_PlayerModelAlpha.IntValue);
}

void OnMapStart_PlayerModel()
{
	gCV_DisableImmunityAlpha.SetInt(1); // Ensures player transparency works
	
	gCV_PlayerModelT.GetString(playerModelT, sizeof(playerModelT));
	gCV_PlayerModelCT.GetString(playerModelCT, sizeof(playerModelCT));
	
	PrecacheModel(playerModelT, true);
	AddFileToDownloadsTable(playerModelT);
	PrecacheModel(playerModelCT, true);
	AddFileToDownloadsTable(playerModelCT);
}



// =========================  PISTOL  ========================= //

static char pistolEntityNames[PISTOL_COUNT][] = 
{
	"weapon_hkp2000", 
	"weapon_glock", 
	"weapon_p250", 
	"weapon_elite", 
	"weapon_deagle", 
	"weapon_cz75a", 
	"weapon_fiveseven", 
	"weapon_tec9"
};

static int pistolTeams[PISTOL_COUNT] = 
{
	CS_TEAM_CT, 
	CS_TEAM_T, 
	CS_TEAM_NONE, 
	CS_TEAM_NONE, 
	CS_TEAM_NONE, 
	CS_TEAM_NONE, 
	CS_TEAM_CT, 
	CS_TEAM_T
};

void UpdatePistol(int client)
{
	GivePistol(client, GetOption(client, Option_Pistol));
}

void OnOptionChanged_Pistol(int client, Option option)
{
	if (option == Option_Pistol)
	{
		UpdatePistol(client);
	}
}

static void GivePistol(int client, int pistol)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}
	
	int playerTeam = GetClientTeam(client);
	bool switchedTeams = false;
	
	// Switch teams to the side that buys that gun so that gun skins load
	if (pistolTeams[pistol] == CS_TEAM_CT && playerTeam != CS_TEAM_CT)
	{
		CS_SwitchTeam(client, CS_TEAM_CT);
		switchedTeams = true;
	}
	else if (pistolTeams[pistol] == CS_TEAM_T && playerTeam != CS_TEAM_T)
	{
		CS_SwitchTeam(client, CS_TEAM_T);
		switchedTeams = true;
	}
	
	// Give the player this pistol
	int currentPistol = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (currentPistol != -1)
	{
		RemovePlayerItem(client, currentPistol);
	}
	GivePlayerItem(client, pistolEntityNames[pistol]);
	
	// Go back to original team
	if (switchedTeams)
	{
		CS_SwitchTeam(client, playerTeam);
	}
}



// =========================  JOIN TEAM HANDLING  ========================= //

static bool hasSavedPosition[MAXPLAYERS + 1];
static float savedOrigin[MAXPLAYERS + 1][3];
static float savedAngles[MAXPLAYERS + 1][3];

void JoinTeam(int client, int team)
{
	if (team == CS_TEAM_SPECTATOR)
	{
		Movement_GetOrigin(client, savedOrigin[client]);
		Movement_GetEyeAngles(client, savedAngles[client]);
		hasSavedPosition[client] = true;
		if (SKZ_GetTimerRunning(client))
		{
			Pause(client);
		}
		ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	}
	else if (team == CS_TEAM_CT || team == CS_TEAM_T)
	{
		// Switch teams without killing them (no death notice)
		CS_SwitchTeam(client, team);
		CS_RespawnPlayer(client);
		if (hasSavedPosition[client])
		{
			Movement_SetOrigin(client, savedOrigin[client]);
			Movement_SetEyeAngles(client, savedAngles[client]);
			hasSavedPosition[client] = false;
		}
		else
		{
			TimerStop(client);
		}
	}
	UpdateTPMenu(client);
}

void OnTimerStart_JoinTeam(int client)
{
	hasSavedPosition[client] = false;
}



// =========================  CHAT PROCESSING  ========================= //

Action OnClientSayCommand_ChatProcessing(int client, const char[] message)
{
	if (!gCV_ChatProcessing.BoolValue)
	{
		return Plugin_Continue;
	}
	
	if (gB_BaseComm && BaseComm_IsClientGagged(client))
	{
		return Plugin_Handled;
	}
	
	// Change to lower case and resend (potential) command messages
	if ((message[0] == '/' || message[0] == '!') && IsCharUpper(message[1]))
	{
		char newMessage[128];
		int length = strlen(message);
		for (int i = 0; i <= length; i++)
		{
			newMessage[i] = CharToLower(message[i]);
		}
		FakeClientCommand(client, "say %s", newMessage);
		return Plugin_Handled;
	}
	
	// Don't print the message if it is a chat trigger, or starts with @, or is empty
	if (IsChatTrigger() || message[0] == '@' || !message[0])
	{
		return Plugin_Handled;
	}
	
	// Print the message to chat
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		SKZ_PrintToChatAll(false, "{bluegrey}%N{default} : %s", client, message);
	}
	else
	{
		SKZ_PrintToChatAll(false, "{lime}%N{default} : %s", client, message);
	}
	return Plugin_Handled;
} 