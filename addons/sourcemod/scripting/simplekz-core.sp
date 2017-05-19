#include <sourcemod>

#include <cstrike>
#include <geoip>
#include <regex>
#include <sdktools>
#include <sdkhooks>

#include <colorvariables>
#include <simplekz>

#include <movementapi>
#include <simplekz/core>

#undef REQUIRE_PLUGIN
#include <basecomm>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "SimpleKZ Core", 
	author = "DanZay", 
	description = "SimpleKZ Core Plugin", 
	version = "0.13.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};

bool gB_LateLoad;
bool gB_BaseComm;
bool gB_SKZLocalRanks;
bool gB_ClientIsSetUp[MAXPLAYERS + 1];

#include "simplekz-core/commands.sp"
#include "simplekz-core/convars.sp"
#include "simplekz-core/forwards.sp"
#include "simplekz-core/natives.sp"
#include "simplekz-core/misc.sp"
#include "simplekz-core/options.sp"
#include "simplekz-core/style.sp"
#include "simplekz-core/teleports.sp"

#include "simplekz-core/hud/hide_csgo_hud.sp"
#include "simplekz-core/hud/info_panel.sp"
#include "simplekz-core/hud/speed_text.sp"
#include "simplekz-core/hud/timer_text.sp"

#include "simplekz-core/map/buttons.sp"
#include "simplekz-core/map/bhop_triggers.sp"
#include "simplekz-core/map/prefix.sp"

#include "simplekz-core/menus/measure.sp"
#include "simplekz-core/menus/options.sp"
#include "simplekz-core/menus/pistol.sp"
#include "simplekz-core/menus/style.sp"
#include "simplekz-core/menus/tp.sp"

#include "simplekz-core/timer/pause.sp"
#include "simplekz-core/timer/timer.sp"
#include "simplekz-core/timer/wasted_time.sp"
#include "simplekz-core/timer/virtual_buttons.sp"



// =========================  PLUGIN  ========================= //

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
	
	CreateRegexes();
	CreateMenus();
	CreateGlobalForwards();
	CreateHooks();
	CreateConVars();
	CreateCommands();
	CreateCommandListeners();
	
	AutoExecConfig(true, "simplekz-core", "sourcemod/simplekz");
	
	if (gB_LateLoad)
	{
		OnLateLoad();
	}
}

void OnLateLoad()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && IsClientAuthorized(client))
		{
			OnClientPostAdminCheck(client);
		}
	}
}

public void OnAllPluginsLoaded()
{
	gB_BaseComm = LibraryExists("basecomm");
	gB_SKZLocalRanks = LibraryExists("simplekz-localranks");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "basecomm"))
	{
		gB_BaseComm = true;
	}
	else if (StrEqual(name, "simplekz-localranks"))
	{
		gB_SKZLocalRanks = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "basecomm"))
	{
		gB_BaseComm = false;
	}
	else if (StrEqual(name, "simplekz-localranks"))
	{
		gB_SKZLocalRanks = false;
	}
}



// =========================  CLIENT  ========================= //

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_PreThinkPost, OnClientPreThink_Post);
	SetupClientOptions(client);
	SetupClientTimer(client);
	SetupClientBhopTriggers(client);
	SetupClientHidePlayers(client);
	PrintConnectMessage(client);
	gB_ClientIsSetUp[client] = true;
	Call_SKZ_OnClientSetup(client);
}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast) // player_disconnect hook
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client))
	{
		return;
	}
	gB_ClientIsSetUp[client] = false;
	PrintDisconnectMessage(client, event);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	if (OnClientSayCommand_ChatProcessing(client, sArgs) == Plugin_Handled)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) // player_spawn hook
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	OnPlayerSpawn_Style(client);
	UpdateCSGOHUD(client);
	UpdateHideWeapon(client);
	UpdatePistol(client);
	UpdatePlayerModel(client);
	UpdateGodMode(client);
	UpdatePlayerCollision(client);
	UpdateTPMenu(client);
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) // player_death hook
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	OnPlayerDeath_Timer(client);
	OnPlayerDeath_Pause(client);
}

public Action OnPlayerJoinTeam(Event event, const char[] name, bool dontBroadcast) // player_team hook
{
	SetEventBroadcast(event, true); // Block join team messages
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	OnPlayerRunCmd_Timer(client);
	OnPlayerRunCmd_Style(client, buttons);
	OnPlayerRunCmd_TPMenu(client);
	OnPlayerRunCmd_InfoPanel(client, tickcount);
	OnPlayerRunCmd_SpeedText(client, tickcount);
	OnPlayerRunCmd_TimerText(client, tickcount);
	return Plugin_Continue;
}

public void OnClientPreThink_Post(int client)
{
	OnClientPreThink_Style(client);
}



// =========================  MOVEMENTAPI  ========================= //

public void Movement_OnButtonPress(int client, int button)
{
	OnButtonPress_VirtualButtons(client, button);
}

public void Movement_OnStartTouchGround(int client)
{
	OnStartTouchGround_Style(client);
}

public void Movement_OnStopTouchGround(int client, bool jumped)
{
	OnStopTouchGround_Style(client, jumped);
}

public void Movement_OnChangeMoveType(int client, MoveType oldMoveType, MoveType newMoveType)
{
	OnChangeMoveType_Style(client, newMoveType);
	OnChangeMoveType_Timer(client, newMoveType);
	OnChangeMoveType_Pause(client, newMoveType);
}



// =========================  SIMPLEKZ  ========================= //

public void SKZ_OnTimerStart_Post(int client, int course, int style)
{
	OnTimerStart_JoinTeam(client);
	OnTimerStart_Pause(client);
	OnTimerStart_Teleports(client);
	OnTimerStart_WastedTime(client);
	UpdateTPMenu(client);
}

public void SKZ_OnTimerEnd_Post(int client, int course, int style, float time, int teleportsUsed, float theoreticalTime)
{
	OnTimerEnd_SlayOnEnd(client);
}

public void SKZ_OnMakeCheckpoint_Post(int client)
{
	OnMakeCheckpoint_WastedTime(client);
	UpdateTPMenu(client);
}

public void SKZ_OnTeleportToCheckpoint_Post(int client)
{
	OnTeleportToCheckpoint_WastedTime(client);
	UpdateTPMenu(client);
}

public void SKZ_OnTeleportToStart_Post(int client)
{
	OnTeleportToStart_Timer(client);
	OnTeleportToStart_WastedTime(client);
	UpdateTPMenu(client);
}

public void SKZ_OnUndoTeleport_Post(int client)
{
	OnUndoTeleport_WastedTime(client);
	UpdateTPMenu(client);
}

public void SKZ_OnOptionChanged(int client, Option option, int newValue)
{
	OnOptionChanged_Timer(client, option);
	OnOptionChanged_TPMenu(client, option);
	OnOptionChanged_HideWeapon(client, option);
	OnOptionChanged_Pistol(client, option);
}



// =========================  OTHER  ========================= //

public void OnMapStart()
{
	OnMapStart_Measure();
	OnMapStart_PlayerModel();
	OnMapStart_KZConfig();
	OnMapStart_Prefix();
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	return Plugin_Handled; // Stop round from ever ending
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) // round_start hook
{
	OnRoundStart_Timer();
	OnRoundStart_ForceAllTalk();
	UpdateMapButtons();
}

public void OnTrigMultTouch(const char[] name, int caller, int activator, float delay)
{
	OnTrigMultTouch_BhopTriggers(activator);
}

public Action OnNormalSound(int[] clients, int &numClients, char[] sample, int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char[] soundEntry, int &seed)
{
	if (OnNormalSound_StopSounds(entity) == Plugin_Handled)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}



// =========================  PRIVATE  ========================= //

static void CreateRegexes()
{
	CreateRegexesMapButtons();
}

static void CreateMenus()
{
	CreateMenusTP();
	CreateMenusOptions();
	CreateMenusStyle();
	CreateMenusPistol();
	CreateMenusMeasure();
}

static void CreateHooks()
{
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("round_start", OnRoundStart, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	HookEntityOutput("trigger_multiple", "OnStartTouch", OnTrigMultTouch);
	AddNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
} 