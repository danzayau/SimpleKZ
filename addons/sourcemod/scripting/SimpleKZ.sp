#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <basecomm>
#include <geoip>
#include <cstrike>

#include <colorvariables>
#include <movement>
#include <movementtweaker>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Simple KZ Core", 
	author = "DanZay", 
	description = "A simple KZ plugin with timer and optional database.", 
	version = "0.7.1", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Definitions  ===============================*/

#define PAUSE_COOLDOWN_AFTER_RESUMING 1.0
#define MINIMUM_SPLIT_TIME 1.0
#define MAX_DISTANCE_FROM_BUTTON_ORIGIN 40.0



/*===============================  Global Variables  ===============================*/

// Timer
bool gB_TimerRunning[MAXPLAYERS + 1] =  { false, ... };
float gF_CurrentTime[MAXPLAYERS + 1];
bool gB_Paused[MAXPLAYERS + 1] =  { false, ... };
float gF_LastResumeTime[MAXPLAYERS + 1];
bool gB_HasResumedInThisRun[MAXPLAYERS + 1] =  { false, ... };

// Saved Positions and Angles
float gF_StartOrigin[MAXPLAYERS + 1][3];
float gF_StartAngles[MAXPLAYERS + 1][3];
int gI_CheckpointsSet[MAXPLAYERS + 1];
int gI_TeleportsUsed[MAXPLAYERS + 1];
float gF_CheckpointOrigin[MAXPLAYERS + 1][3];
float gF_CheckpointAngles[MAXPLAYERS + 1][3];
bool gB_LastTeleportOnGround[MAXPLAYERS + 1];
float gF_UndoOrigin[MAXPLAYERS + 1][3];
float gF_UndoAngle[MAXPLAYERS + 1][3];

// Button Press Checking
bool gB_HasStartedThisMap[MAXPLAYERS + 1] =  { false, ... };
bool gB_HasEndedThisMap[MAXPLAYERS + 1] =  { false, ... };
float gF_StartButtonOrigin[MAXPLAYERS + 1][3];
float gF_EndButtonOrigin[MAXPLAYERS + 1][3];

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

// Database
Database gH_DB = null;
bool gB_ConnectedToDB = false;
DatabaseType g_DBType = NONE;
char gC_SteamID[MAXPLAYERS + 1][24];
char gC_Country[MAXPLAYERS + 1][45];

// Preferences
bool gB_ShowingTeleportMenu[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingInfoPanel[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingKeys[MAXPLAYERS + 1] =  { false, ... };
bool gB_ShowingPlayers[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingWeapon[MAXPLAYERS + 1] =  { true, ... };
bool gB_AutoRestart[MAXPLAYERS + 1] =  { false, ... };
bool gB_SlayOnEnd[MAXPLAYERS + 1] =  { false, ... };
int gI_Pistol[MAXPLAYERS + 1] =  { 0, ... };

// Menus
Handle gH_PistolMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_TeleportMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
bool gB_TeleportMenuIsShowing[MAXPLAYERS + 1] =  { false, ... };
Handle gH_OptionsMenu[MAXPLAYERS + 1];
bool gB_CameFromOptionsMenu[MAXPLAYERS + 1];

// Measure
Handle gH_MeasureMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
int gI_GlowSprite;
bool gB_MeasurePosSet[MAXPLAYERS + 1][2];
float gF_MeasurePos[MAXPLAYERS + 1][2][3];
Handle gH_P2PRed[MAXPLAYERS + 1];
Handle gH_P2PGreen[MAXPLAYERS + 1];

// Splits
int gI_Splits[MAXPLAYERS + 1];
float gF_SplitRunTime[MAXPLAYERS + 1];
float gF_SplitGameTime[MAXPLAYERS + 1];

// Other
MovementPlayer g_MovementPlayer[MAXPLAYERS + 1];
bool gB_CurrentMapIsKZPro;
int g_OldButtons[MAXPLAYERS + 1];
ConVar gCV_FullAlltalk;

// Pistol Entity Names (entity class name, alias, team that buys it)
char gC_Pistols[][][] = 
{
	{ "weapon_hkp2000", "P2000 / USP-S", "CT" }, 
	{ "weapon_glock", "Glock-18", "T" }, 
	{ "weapon_p250", "P250", "EITHER" }, 
	{ "weapon_elite", "Dual Berettas", "EITHER" }, 
	{ "weapon_deagle", "Deagle", "EITHER" }, 
	{ "weapon_cz75a", "CZ75-Auto", "EITHER" }, 
	{ "weapon_fiveseven", "Five-SeveN", "CT" }, 
	{ "weapon_tec9", "Tec-9", "T" }
};

// Radio commands
char gC_RadioCommands[][] =  { "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", 
	"fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", 
	"inposition", "reportingin", "getout", "negative", "enemydown", "compliment", "thanks", "cheer" };



/*===============================  Includes  ===============================*/

// Global Variable Includes
#include "SimpleKZ/sql.sp"

#include "SimpleKZ/api.sp"
#include "SimpleKZ/commands.sp"
#include "SimpleKZ/convars.sp"
#include "SimpleKZ/database.sp"
#include "SimpleKZ/infopanel.sp"
#include "SimpleKZ/menus.sp"
#include "SimpleKZ/misc.sp"
#include "SimpleKZ/timer.sp"



/*===============================  Plugin Events  ===============================*/

public void OnPluginStart() {
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO) {
		SetFailState("This plugin is only for CS:GO.");
	}
	
	CreateGlobalForwards();
	RegisterConVars();
	AutoExecConfig(true, "SimpleKZ", "sourcemod/SimpleKZ");
	RegisterCommands();
	AddCommandListeners();
	
	// Hooks
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("round_start", OnRoundStart, EventHookMode_Pre);
	HookEntityOutput("func_button", "OnPressed", OnButtonPress);
	AddCommandListener(OnSay, "say");
	AddCommandListener(OnSay, "say_team");
	AddNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
	gCV_FullAlltalk = FindConVar("sv_full_alltalk");
	
	// Translations
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz.phrases");
	
	// Setup
	SetupMovementMethodmaps();
	CreateMenus();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNatives();
	RegPluginLibrary("SimpleKZ");
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name) {
	// Send database info if dependent plugins load late
	if (StrEqual(name, "SimpleKZRanks")) {
		if (gB_ConnectedToDB) {
			Call_SimpleKZ_OnDatabaseConnect();
		}
	}
}



/*===============================  Map and Client Events  ===============================*/

public void OnMapStart() {
	LoadKZConfig();
	DB_SetupDatabase();
	OnMapStartVariableUpdates();
}

public void OnClientAuthorized(int client) {
	// Prepare for client arrival
	if (!IsFakeClient(client)) {
		GetClientCountry(client);
		GetClientSteamID(client);
		DB_SavePlayerInfo(client);
		DB_LoadPreferences(client);
		
		UpdatePistolMenu(client);
		UpdateMeasureMenu(client);
		UpdateOptionsMenu(client);
		TimerSetup(client);
		MeasureResetPos(client);
		SplitsSetup(client);
	}
}

public void OnClientPutInServer(int client) {
	if (!IsFakeClient(client)) {
		SDKHook(client, SDKHook_SetTransmit, OnSetTransmit);
		PrintConnectMessage(client);
	}
}

public void OnClientDisconnect(int client) {  // Also calls at end of map
	if (!IsFakeClient(client)) {
		DB_SavePreferences(client);
	}
}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidClient(client) && !IsFakeClient(client)) {
		SetEventBroadcast(event, true);
		char reason[64];
		GetEventString(event, "reason", reason, sizeof(reason));
		PrintDisconnectMessage(client, reason);
	}
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client)) {
		CreateTimer(0.0, CleanHUD, client); // Clean HUD (using a 1 frame timer or else it won't work)
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); // Godmode
		SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true); // No Block
		SetDrawViewModel(client, gB_ShowingWeapon[client]); // Hide weapon
		GivePlayerPistol(client, gI_Pistol[client]); // Give player their preferred pistol
		CloseTeleportMenu(client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	TimerTick(client);
	UpdateTeleportMenu(client);
	UpdateInfoPanel(client);
	CheckForStartButtonPress(client);
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

// Block join team messages
public Action OnPlayerJoinTeam(Event event, const char[] name, bool dontBroadcast) {
	SetEventBroadcast(event, true);
	return Plugin_Continue;
}

// Adjust player messages, and automatically lower case commands
public Action OnSay(int client, const char[] command, int argc) {
	if (!GetConVarBool(gCV_Chat)) {
		return Plugin_Continue;
	}
	
	if (BaseComm_IsClientGagged(client)) {
		return Plugin_Handled;
	}
	
	char message[128];
	GetCmdArgString(message, sizeof(message));
	StripQuotes(message);
	
	// Change to lower case (potential) command messages
	if ((message[0] == '/' || message[0] == '!') && IsCharUpper(message[1])) {
		for (int i = 1; i <= strlen(message); i++) {
			message[i] = CharToLower(message[i]);
		}
		FakeClientCommand(client, "say %s", message);
		return Plugin_Handled;
	}
	
	// Don't print the message if it is a chat trigger, or starts with @, or is empty
	if (IsChatTrigger() || message[0] == '@' || !message[0]) {
		return Plugin_Handled;
	}
	
	// Print the message to chat
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR) {
		CPrintToChatAll("{bluegrey}%N{default}: %s", client, message);
	}
	else {
		CPrintToChatAll("{lime}%N{default}: %s", client, message);
	}
	return Plugin_Handled;
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
		CPrintToChat(client, "%t %t", "KZ_Tag", "TimeStopped_Noclip");
		SimpleKZ_ForceStopTimer(client);
	}
}

// Force stop timer when a player dies
public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client)) {
		SimpleKZ_ForceStopTimer(client);
	}
}

// Force full alltalk on round start
public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	SetConVarInt(gCV_FullAlltalk, 1);
} 