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
#include "simplekz-core/hud.sp"
#include "simplekz-core/mapping_api.sp"
#include "simplekz-core/menus.sp"
#include "simplekz-core/misc.sp"
#include "simplekz-core/movement_tweak.sp"
#include "simplekz-core/options.sp"
#include "simplekz-core/timer.sp"



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
	NoBhopCPSetupClient(client);
}

public void OnClientPutInServer(int client)
{
	HidePlayersOnClientPutInServer(client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	TimerOnPlayerRunCmd(client);
	MovementTweakOnPlayerRunCmd(client);
	ButtonPressOnPlayerRunCmd(client);
	TPMenuUpdate(client);
	InfoPanelUpdate(client);
	TimerTextUpdate(client);
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
	CloseTPMenu(client);
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



/*===============================  Movement API Forwads  ===============================*/

public void OnStartTouchGround(int client)
{
	MovementTweakOnStartTouchGround(client);
}

public void OnStopTouchGround(int client, bool jumped, bool ducked, bool landed)
{
	MovementTweakOnStopTouchGround(client, jumped, ducked);
}

public void OnStopTouchLadder(int client)
{
	MovementTweakOnStopTouchLadder(client);
}

public void OnStartNoclipping(int client)
{
	TimerForceStopOnStartNoclipping(client);
	PauseOnStartNoclipping(client);
}

public void OnStopNoclipping(int client)
{
	MovementTweakOnStopNoclipping(client);
}



/*===============================  Other Forwards  ===============================*/

public void OnMapStart()
{
	MeasureOnMapStart();
	PlayerModelOnMapStart();
	KZConfigOnMapStart();
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	return Plugin_Handled; // Stop round from ever ending
}

public Action OnPlayerJoinTeam(Event event, const char[] name, bool dontBroadcast) // player_team hook
{
	SetEventBroadcast(event, true); // Block join team messages
	return Plugin_Continue;
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) // round_start hook
{
	ForceAllTalkOnRoundStart();
	TimerForceStopOnRoundStart();
	MappingAPIUpdate();
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
	MappingAPICreateRegexes();
}

void CreateHooks()
{
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_connect", OnPlayerConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	HookEvent("round_start", OnRoundStart, EventHookMode_Pre);
	StopSoundsCreateHooks();
	NoBhopCPCreateHooks();
}

void CreateCommandListeners()
{
	JoinTeamAddCommandListeners();
	BlockRadioAddCommandListeners();
} 