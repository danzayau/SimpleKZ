#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <geoip>
#include <movement>
#include <movementtweaker>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

Plugin myinfo = 
{
	name = "Simple KZ", 
	author = "DanZay", 
	description = "A simple KZ plugin with timer and optional database.", 
	version = "0.5", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Definitions  ===============================*/

#define PAUSE_COOLDOWN_AFTER_RESUMING 0.5
#define NUMBER_OF_PISTOLS 8

#define NONE -1
#define MYSQL 0
#define SQLITE 1



/*===============================  Global Variables  ===============================*/

// Timer
bool gB_TimerRunning[MAXPLAYERS + 1] =  { false, ... };
float gF_CurrentTime[MAXPLAYERS + 1];
bool gB_Paused[MAXPLAYERS + 1] =  { false, ... };
float gF_LastResumeTime[MAXPLAYERS + 1];
bool gB_HasResumedInThisRun[MAXPLAYERS + 1] =  { false, ... };

// Checkpoints and Teleports
bool gB_HasStartedThisMap[MAXPLAYERS + 1] =  { false, ... };
float gF_StartOrigin[MAXPLAYERS + 1][3];
float gF_StartAngles[MAXPLAYERS + 1][3];
int gI_CheckpointsSet[MAXPLAYERS + 1];
int gI_TeleportsUsed[MAXPLAYERS + 1];
float gF_CheckpointOrigin[MAXPLAYERS + 1][3];
float gF_CheckpointAngles[MAXPLAYERS + 1][3];
bool gB_LastTeleportOnGround[MAXPLAYERS + 1];
float gF_UndoOrigin[MAXPLAYERS + 1][3];
float gF_UndoAngle[MAXPLAYERS + 1][3];

// Wasted Time
float gF_LastCheckpointTime[MAXPLAYERS + 1];
float gF_LastGoCheckTime[MAXPLAYERS + 1];
float gF_LastGoCheckWastedTime[MAXPLAYERS + 1];
float gF_LastUndoTime[MAXPLAYERS + 1];
float gF_LastUndoWastedTime[MAXPLAYERS + 1];
float gF_LastTeleportToStartTime[MAXPLAYERS + 1];
float gF_LastTeleportToStartWastedTime[MAXPLAYERS + 1];
float gF_WastedTime[MAXPLAYERS + 1];

// Position Restoration
bool gB_HasSavedPosition[MAXPLAYERS + 1] =  { false, ... };
float gF_SavedOrigin[MAXPLAYERS + 1][3];
float gF_SavedAngles[MAXPLAYERS + 1][3];

// Measure
Handle gH_MeasureMenu = INVALID_HANDLE;
int gI_GlowSprite;
bool gB_MeasurePosSet[MAXPLAYERS + 1][2];
float gF_MeasurePos[MAXPLAYERS + 1][2][3];
Handle gH_P2PRed[MAXPLAYERS + 1];
Handle gH_P2PGreen[MAXPLAYERS + 1];

// Database
Database gH_DB = null;
bool gB_ConnectedToDB = false;
int g_DBType = NONE;
char gC_CurrentMap[32];
char gC_SteamID[MAXPLAYERS + 1][24];
char gC_Country[MAXPLAYERS + 1][45];

bool gB_ShowingTeleportMenu[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingInfoPanel[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingKeys[MAXPLAYERS + 1] =  { false, ... };
bool gB_ShowingPlayers[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingWeapon[MAXPLAYERS + 1] =  { true, ... };
int gI_Pistol[MAXPLAYERS + 1] =  { 0, ... };

// Other
MovementPlayer g_MovementPlayer[MAXPLAYERS + 1];
Handle gH_PistolMenu = INVALID_HANDLE;
Handle gH_TeleportMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
bool gB_TeleportMenuIsShowing[MAXPLAYERS + 1] =  { false, ... };
Handle gH_MapTopMenu[MAXPLAYERS + 1] = INVALID_HANDLE;
char gC_MapTopMap[MAXPLAYERS + 1][33];
Handle gH_MapTopSubmenu[MAXPLAYERS + 1] = INVALID_HANDLE;



/*===============================  Includes  ===============================*/

#include "SimpleKZ/commands.sp"
#include "SimpleKZ/timer.sp"
#include "SimpleKZ/infopanel.sp"
#include "SimpleKZ/menus.sp"
#include "SimpleKZ/misc.sp"
#include "SimpleKZ/database.sp"
#include "SimpleKZ/api.sp"



/*===============================  Plugin Events  ===============================*/

public void OnPluginStart() {
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO) {
		SetFailState("This plugin is for CS:GO.");
	}
	
	CreateGlobalForwards();
	RegisterCommands();
	AddCommandListeners();
	
	// Hooks
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	HookEntityOutput("func_button", "OnPressed", OnButtonPress);
	AddNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
	
	// Translations
	LoadTranslations("common.phrases");
	
	// Setup
	SetupMovementMethodmaps();
	SetupMenus();
	DB_SetupDatabase();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNatives();
	RegPluginLibrary("SimpleKZ");
	return APLRes_Success;
}



/*===============================  Map and Client Events  ===============================*/

public void OnMapStart() {
	LoadKZConfig();
	OnMapStartVariableUpdates();
	
	DB_SaveMapInfo();
}

public void OnClientAuthorized(int client) {
	if (!IsFakeClient(client)) {
		GetClientCountry(client);
		GetClientSteamID(client);
		DB_SavePlayerInfo(client);
		DB_LoadPreferences(client);
	}
}

public void OnClientPutInServer(int client) {
	// Get rid of bots when they join
	if (IsFakeClient(client)) {
		ServerCommand("bot_quota 0");
	}
	else {
		SetupTimer(client);
		MeasureResetPos(client);
		SDKHook(client, SDKHook_SetTransmit, OnSetTransmit);
	}
}

public void OnClientDisconnect(int client) {
	DB_UpdatePreferences(client);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client)) {
		CreateTimer(0.0, CleanHUD, client); // Clean HUD (using a 1 frame timer or else it won't work)
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); // Godmode
		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true); // No Block
		SetDrawViewModel(client, gB_ShowingWeapon[client]); // Hide weapon
		GivePlayerPistol(client, gI_Pistol[client]); // Give player their preferred pistol
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	TimerTick(client);
	UpdateTeleportMenu(client);
	UpdateInfoPanel(client);
}



/*===============================  Miscellaneous Events  ===============================*/

// Stop round from ever ending
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason) {
	return Plugin_Handled;
}

// Hide other players
public Action OnSetTransmit(int entity, int client) {
	if (!gB_ShowingPlayers[client] && entity != client && entity != GetSpectatedPlayer(client)) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

// Allow unlimited team changes
public Action CommandJoinTeam(int client, const char[] command, int argc) {
	char teamString[4];
	GetCmdArgString(teamString, sizeof(teamString));
	int team = StringToInt(teamString);
	JoinTeam(client, team);
	return Plugin_Handled;
}

// Stop join team messages from showing up
public Action OnPlayerJoinTeam(Event event, const char[] name, bool dontBroadcast) {
	SetEventBroadcast(event, true);
	return Plugin_Continue;
}

// Prevent sounds
public Action OnNormalSound(int[] clients, int &numClients, char[] sample, int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char[] soundEntry, int &seed) {
	char className[20];
	GetEntityClassname(entity, className, sizeof(className));
	// Prevent func_button sounds
	if (StrEqual(className, "func_button", false)) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

// Prevent noclipping during runs
public void OnStartNoclipping(int client) {
	if (gB_TimerRunning[client]) {
		PrintToChat(client, "[\x06KZ\x01] Your time has been stopped because you used noclip.");
	}
	ForceStopTimer(client);
} 