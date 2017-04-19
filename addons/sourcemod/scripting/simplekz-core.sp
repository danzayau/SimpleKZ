#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <regex>
#include <cstrike>
#include <basecomm>
#include <geoip>
#include <colorvariables>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "Simple KZ Core", 
	author = "DanZay", 
	description = "The best KZ plugin.", 
	version = "0.11.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



#include "simplekz-core/global_variables.sp"

#include "simplekz-core/api.sp"
#include "simplekz-core/commands.sp"
#include "simplekz-core/convars.sp"
#include "simplekz-core/misc.sp"
#include "simplekz-core/options.sp"
#include "simplekz-core/style.sp"

#include "simplekz-core/timer/timer.sp"
#include "simplekz-core/timer/force_stop.sp"
#include "simplekz-core/timer/pause.sp"
#include "simplekz-core/timer/wasted_time.sp"

#include "simplekz-core/map/buttons.sp"
#include "simplekz-core/map/bhop_triggers.sp"
#include "simplekz-core/map/kzpro.sp"

#include "simplekz-core/hud/hide_csgo_hud.sp"
#include "simplekz-core/hud/info_panel.sp"
#include "simplekz-core/hud/speed_text.sp"
#include "simplekz-core/hud/timer_text.sp"

#include "simplekz-core/menus/measure.sp"
#include "simplekz-core/menus/options.sp"
#include "simplekz-core/menus/pistol.sp"
#include "simplekz-core/menus/style.sp"
#include "simplekz-core/menus/tp.sp"

#include "simplekz-core/misc/block_radio.sp"
#include "simplekz-core/misc/button_press.sp"
#include "simplekz-core/misc/chat_processing.sp"
#include "simplekz-core/misc/god_mode.sp"
#include "simplekz-core/misc/hide_players.sp"
#include "simplekz-core/misc/hide_weapon.sp"
#include "simplekz-core/misc/measure.sp"
#include "simplekz-core/misc/pistol.sp"
#include "simplekz-core/misc/player_collision.sp"
#include "simplekz-core/misc/player_model.sp"
#include "simplekz-core/misc/stop_sounds.sp"
#include "simplekz-core/misc/teleports.sp"
#include "simplekz-core/misc/other.sp"



/*===============================  Plugin Forwards  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("simplekz-core");
	gB_LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("This plugin is only for CS:GO.");
	}
	
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz-core.phrases");
	
	CreateKZPlayers();
	CreateRegexes();
	CreateMenus();
	CreateGlobalForwards();
	CreateHooks();
	CreateConVars();
	CreateCommands();
	CreateCommandListeners();
	
	AutoExecConfig(true, "simplekz-core", "sourcemod/SimpleKZ");
	
	if (gB_LateLoad)
	{
		OnLateLoad();
	}
}

void OnLateLoad()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
		}
	}
}



/*===============================  Client Forwards  ===============================*/

public void OnClientConnected(int client)
{
	OptionsSetupClient(client);
	TimerSetupClient(client);
	BhopTriggersSetupClient(client);
}

public void OnClientPutInServer(int client)
{
	HidePlayersOnClientPutInServer(client);
	SDKHook(client, SDKHook_PreThinkPost, OnClientPreThinkPost);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	return ChatProcessingOnClientSayCommand(client, sArgs);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) // player_spawn hook
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	HideCSGOHUD(client);
	HideWeaponUpdate(client);
	PistolUpdate(client);
	PlayerModelUpdate(client);
	GodModeUpdate(client);
	PlayerCollisionUpdate(client);
	TPMenuUpdate(client);
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) // player_death hook
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	TimerForceStopOnPlayerDeath(client);
}

public void OnPlayerConnect(Event event, const char[] name, bool dontBroadcast) // player_connect hook
{
	PrintConnectMessage(event);
}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast) // player_disconnect hook
{
	PrintDisconnectMessage(event);
}

public Action OnPlayerJoinTeam(Event event, const char[] name, bool dontBroadcast) // player_team hook
{
	SetEventBroadcast(event, true); // Block join team messages
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	TimerUpdate(client);
	TimerTextUpdate(client); // After updating timer!
	ButtonPressOnPlayerRunCmd(client); // After updating timer!
	StyleOnPlayerRunCmd(client, buttons);
	InfoPanelUpdate(client);
	SpeedTextUpdate(client);
	TPMenuDisplay(client);
}

public void OnClientPreThinkPost(int client)
{
	StyleOnClientPreThinkPost(client);
}



/*===============================  Movement API Forwards  ===============================*/

public void Movement_OnStartTouchGround(int client)
{
	StyleOnStartTouchGround(client);
}

public void Movement_OnStopTouchGround(int client, bool jumped, bool ducked, bool landed)
{
	StyleOnStopTouchGround(client, jumped);
}

public void Movement_OnStopTouchLadder(int client)
{
	StyleOnStopTouchLadder(client);
}

public void Movement_OnStartNoclipping(int client)
{
	TimerForceStopOnStartNoclipping(client);
	PauseOnStartNoclipping(client);
}

public void Movement_OnStopNoclipping(int client)
{
	StyleOnStopNoclipping(client);
}



/*===============================  SimpleKZ Forwards  ===============================*/

public void SKZ_OnTeleportToStart(int client)
{
	TimerForceStopOnTeleportToStart(client);
	WastedTimeOnTeleportToStart(client);
}

public void SKZ_OnTeleportToCheckpoint(int client)
{
	WastedTimeOnTeleportToCheckpoint(client);
}

public void SKZ_OnUndoTeleport(int client)
{
	WastedTimeOnUndoTeleport(client);
}

public void SKZ_OnChangeOption(int client, KZOption option, any newValue)
{
	switch (option)
	{
		case KZOption_Style:TimerForceStopOnChangeStyle(client);
		case KZOption_ShowingTPMenu:TPMenuUpdate(client);
		case KZOption_ShowingWeapon:HideWeaponUpdate(client);
		case KZOption_Pistol:PistolUpdate(client);
	}
}



/*===============================  Other Forwards  ===============================*/

public void OnMapStart()
{
	MeasureOnMapStart();
	PlayerModelOnMapStart();
	KZConfigOnMapStart();
	KZProOnMapStart();
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	return Plugin_Handled; // Stop round from ever ending
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) // round_start hook
{
	ForceAllTalkOnRoundStart();
	TimerForceStopOnRoundStart();
	MapButtonsUpdate();
}

public void OnTrigMultiTouch(const char[] name, int caller, int activator, float delay)
{
	BhopTriggersOnTrigMultiTouch(activator);
}



/*===============================  Functions  ===============================*/

void CreateKZPlayers()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		g_KZPlayer[client] = new KZPlayer(client);
	}
}

void CreateRegexes()
{
	MapButtonsCreateRegexes();
}

void CreateMenus()
{
	TPMenuCreateMenus();
	OptionsMenuCreateMenus();
	StyleMenuCreateMenus();
	PistolMenuCreateMenus();
	MeasureMenuCreateMenus();
}

void CreateHooks()
{
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_connect", OnPlayerConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("round_start", OnRoundStart, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	HookEntityOutput("trigger_multiple", "OnStartTouch", OnTrigMultiTouch);
	StopSoundsCreateHooks();
}

void CreateCommandListeners()
{
	JoinTeamAddCommandListeners();
	BlockRadioAddCommandListeners();
} 