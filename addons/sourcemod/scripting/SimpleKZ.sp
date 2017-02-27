#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <regex>
#include <cstrike>

#include <basecomm>
#include <geoip>

#include <colorvariables>
#include <movement>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Simple KZ Core", 
	author = "DanZay", 
	description = "A simple KZ plugin with timer and optional database.", 
	version = "0.9.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Definitions  ===============================*/

#define TIME_PAUSE_COOLDOWN 1.0
#define TIME_SPLIT_COOLDOWN 1.0
#define TIME_BHOP_TRIGGER_DETECTION 0.2
#define DISTANCE_BUTTON_PRESS_CHECK 40.0

#define SPEED_NORMAL 250.0 // Desired speed when just holding down W and running
#define SPEED_NO_WEAPON 260.0 // Max speed with no weapon and just holding down W and running
#define PRESTRAFE_VELMOD_MAX 1.104 // Calculated 276/250
#define PRESTRAFE_VELMOD_INCREMENT 0.0014
#define PRESTRAFE_VELMOD_DECREMENT 0.0021
#define VELOCITY_VERTICAL_NORMAL_JUMP 292.54 // Found by testing until binding resulted in similar jump height to normal
#define DUCK_SPEED_MINIMUM 7.0

#define STYLE_DEFAULT_PERF_TICKS 2
#define STYLE_LEGACY_PERF_TICKS 1
#define STYLE_LEGACY_PERF_SPEED_CAP 380.0



/*===============================  Global Variables  ===============================*/

/* ConVars */
ConVar gCV_FullAlltalk;
ConVar gCV_DefaultStyle;
ConVar gCV_CustomChat;
ConVar gCV_PlayerModelT;
ConVar gCV_PlayerModelCT;

/* Movement Tweaker */
MovementPlayer g_MovementPlayer[MAXPLAYERS + 1];
MovementStyle g_Style[MAXPLAYERS + 1];
float gF_PrestrafeVelocityModifier[MAXPLAYERS + 1];
bool gB_HitPerf[MAXPLAYERS + 1];
char gC_PlayerModelT[256];
char gC_PlayerModelCT[256];

/* Timer */
bool gB_TimerRunning[MAXPLAYERS + 1] =  { false, ... };
float gF_CurrentTime[MAXPLAYERS + 1];
bool gB_Paused[MAXPLAYERS + 1] =  { false, ... };
float gF_LastResumeTime[MAXPLAYERS + 1];
bool gB_HasResumedInThisRun[MAXPLAYERS + 1] =  { false, ... };
int gI_CurrentCourse[MAXPLAYERS + 1];

/* Button Press Checking */
int gI_OldButtons[MAXPLAYERS + 1];
Regex gRE_BonusStartButton;
Regex gRE_BonusEndButton;
bool gB_HasStartedThisMap[MAXPLAYERS + 1] =  { false, ... };
bool gB_HasEndedThisMap[MAXPLAYERS + 1] =  { false, ... };
float gF_StartButtonOrigin[MAXPLAYERS + 1][3];
float gF_EndButtonOrigin[MAXPLAYERS + 1][3];
int gI_LastCourseStarted[MAXPLAYERS + 1];
int gI_LastCourseEnded[MAXPLAYERS + 1];

/* Wasted Time */
float gF_LastCheckpointTime[MAXPLAYERS + 1];
float gF_LastGoCheckTime[MAXPLAYERS + 1];
float gF_LastGoCheckWastedTime[MAXPLAYERS + 1];
float gF_LastUndoTime[MAXPLAYERS + 1];
float gF_LastUndoWastedTime[MAXPLAYERS + 1];
float gF_LastTeleportToStartTime[MAXPLAYERS + 1];
float gF_LastTeleportToStartWastedTime[MAXPLAYERS + 1];
float gF_WastedTime[MAXPLAYERS + 1];

/* Saved Positions and Angles */
float gF_StartOrigin[MAXPLAYERS + 1][3];
float gF_StartAngles[MAXPLAYERS + 1][3];
int gI_CheckpointCount[MAXPLAYERS + 1];
int gI_TeleportsUsed[MAXPLAYERS + 1];
float gF_CheckpointOrigin[MAXPLAYERS + 1][3];
float gF_CheckpointAngles[MAXPLAYERS + 1][3];
bool gB_LastTeleportOnGround[MAXPLAYERS + 1];
float gF_UndoOrigin[MAXPLAYERS + 1][3];
float gF_UndoAngle[MAXPLAYERS + 1][3];
float gF_PauseAngles[MAXPLAYERS + 1][3];

/* Position Restoration */
bool gB_HasSavedPosition[MAXPLAYERS + 1] =  { false, ... };
float gF_SavedOrigin[MAXPLAYERS + 1][3];
float gF_SavedAngles[MAXPLAYERS + 1][3];

/* Database */
Database gH_DB = null;
bool gB_ConnectedToDB = false;
DatabaseType g_DBType = DatabaseType_None;
int gI_PlayerID[MAXPLAYERS + 1];

/* Menus */
Handle gH_PistolMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_TeleportMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
bool gB_TeleportMenuIsShowing[MAXPLAYERS + 1] =  { false, ... };
Handle gH_OptionsMenu[MAXPLAYERS + 1];
bool gB_CameFromOptionsMenu[MAXPLAYERS + 1];
Handle gH_MovementStyleMenu[MAXPLAYERS + 1];

/* Preferences */
bool gB_ShowingTeleportMenu[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingInfoPanel[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingKeys[MAXPLAYERS + 1] =  { false, ... };
bool gB_ShowingPlayers[MAXPLAYERS + 1] =  { true, ... };
bool gB_ShowingWeapon[MAXPLAYERS + 1] =  { true, ... };
bool gB_AutoRestart[MAXPLAYERS + 1] =  { false, ... };
bool gB_SlayOnEnd[MAXPLAYERS + 1] =  { false, ... };
int gI_Pistol[MAXPLAYERS + 1] =  { 0, ... };

/* Measure */
Handle gH_MeasureMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
int gI_GlowSprite;
bool gB_MeasurePosSet[MAXPLAYERS + 1][2];
float gF_MeasurePos[MAXPLAYERS + 1][2][3];
Handle gH_P2PRed[MAXPLAYERS + 1];
Handle gH_P2PGreen[MAXPLAYERS + 1];

/* Splits */
int gI_Splits[MAXPLAYERS + 1];
float gF_SplitRunTime[MAXPLAYERS + 1];
float gF_SplitGameTime[MAXPLAYERS + 1];

/* Other */
bool gB_LateLoad;
char gC_CurrentMap[64];
bool gB_CurrentMapIsKZPro;
int gI_JustTouchedTrigMulti[MAXPLAYERS + 1];

/* Weapon entity names */
char gC_WeaponNames[][] = 
{ "weapon_ak47", "weapon_aug", "weapon_awp", "weapon_bizon", "weapon_deagle", 
	"weapon_decoy", "weapon_elite", "weapon_famas", "weapon_fiveseven", "weapon_flashbang", 
	"weapon_g3sg1", "weapon_galilar", "weapon_glock", "weapon_hegrenade", "weapon_hkp2000", 
	"weapon_incgrenade", "weapon_knife", "weapon_m249", "weapon_m4a1", "weapon_mac10", 
	"weapon_mag7", "weapon_molotov", "weapon_mp7", "weapon_mp9", "weapon_negev", 
	"weapon_nova", "weapon_p250", "weapon_p90", "weapon_sawedoff", "weapon_scar20", 
	"weapon_sg556", "weapon_smokegrenade", "weapon_ssg08", "weapon_taser", "weapon_tec9", 
	"weapon_ump45", "weapon_xm1014" };

/* Max movement speed of weapons (respective to gC_WeaponNames). */
int gI_WeaponRunSpeeds[] = 
{ 215, 220, 200, 240, 230, 
	245, 240, 220, 240, 245, 
	215, 215, 240, 245, 240, 
	245, 250, 195, 225, 240, 
	225, 245, 220, 240, 195, 
	220, 240, 230, 210, 215, 
	210, 245, 230, 240, 240, 
	230, 215 };

/* Pistol Entity Names (entity name | alias | team that buys it) */
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

/* Radio commands */
char gC_RadioCommands[][] =  { "coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", 
	"fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", 
	"inposition", "reportingin", "getout", "negative", "enemydown", "compliment", "thanks", "cheer" };

/* Styles translation phrases for chat messages (respective to MovementStyle enum) */
char gC_StylePhrases[SIMPLEKZ_NUMBER_OF_STYLES][] = 
{ "Style - Standard", 
	"Style - Legacy"
};



/*===============================  Includes  ===============================*/

/* Global variable includes */
#include "SimpleKZ/sql.sp"

#include "SimpleKZ/api.sp"
#include "SimpleKZ/convars.sp"
#include "SimpleKZ/commands.sp"
#include "SimpleKZ/database.sp"
#include "SimpleKZ/infopanel.sp"
#include "SimpleKZ/menus.sp"
#include "SimpleKZ/misc.sp"
#include "SimpleKZ/movementtweaker.sp"
#include "SimpleKZ/timer.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNatives();
	RegPluginLibrary("SimpleKZ");
	gB_LateLoad = late;
	return APLRes_Success;
}

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
	HookEntityOutput("trigger_multiple", "OnStartTouch", OnTrigMultiStartTouch);
	AddCommandListener(OnSay, "say");
	AddCommandListener(OnSay, "say_team");
	AddNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
	
	// Translations
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz.phrases");
	
	// Setup
	SetupMovementMethodmaps();
	CreateMenus();
	CompileRegexes();
	DB_SetupDatabase();
	
	if (gB_LateLoad) {
		OnLateLoad();
	}
}

public void OnLibraryAdded(const char[] name) {
	// Send database info if dependent plugins load late
	if (StrEqual(name, "SimpleKZRanks")) {
		if (gB_ConnectedToDB) {
			Call_SimpleKZ_OnDatabaseConnect();
		}
	}
}

void OnLateLoad() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientAuthorized(client) && !IsFakeClient(client)) {
			SetupClient(client);
		}
		if (IsClientInGame(client)) {
			OnClientPutInServer(client);
		}
	}
}



/*===============================  Client Events  ===============================*/

public void OnClientAuthorized(int client, const char[] auth) {
	// Prepare for client arrival
	if (!IsFakeClient(client)) {
		SetupClient(client);
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
		DB_SaveOptions(client);
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
		UpdatePlayerModel(GetClientOfUserId(GetEventInt(event, "userid"))); // Change player model to one that doesn't have landing animation
		CloseTeleportMenu(client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	TimerTick(client);
	UpdateTeleportMenu(client); // Can be moved to a slower timer
	UpdateInfoPanel(client); // Can be moved to a slower timer
	CheckForTimerButtonPress(client);
	MovementTweakGeneral(g_MovementPlayer[client]);
}

// Adjust player messages, and automatically lower case commands
public Action OnSay(int client, const char[] command, int argc) {
	if (!GetConVarBool(gCV_CustomChat)) {
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
		CPrintToChatAll("{bluegrey}%N{default} : %s", client, message);
	}
	else {
		CPrintToChatAll("{lime}%N{default} : %s", client, message);
	}
	return Plugin_Handled;
}

// Force stop timer when they enter noclip
public void OnStartNoclipping(int client) {
	if (!IsFakeClient(client) && gB_TimerRunning[client]) {
		TimerForceStop(client);
		gB_Paused[client] = false;
		CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped (Noclipped)");
	}
}

// Force stop timer when a player dies
public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client) && gB_TimerRunning[client]) {
		TimerForceStop(client);
	}
}



/*===============================  Miscellaneous Events  ===============================*/

public void OnMapStart() {
	LoadKZConfig();
	PrecacheModels();
	SetupMap();
}

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

// Force full alltalk on round start
public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	SetConVarInt(gCV_FullAlltalk, 1);
	TimerForceStopAll();
} 