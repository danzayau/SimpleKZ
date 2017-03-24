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

/* Formatted using SPEdit Syntax Reformatter - https://github.com/JulienKluge/Spedit */

public Plugin myinfo = 
{
	name = "Simple KZ Core", 
	author = "DanZay", 
	description = "A simple KZ timer plugin.", 
	version = "0.10.0", 
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

#define STYLE_DEFAULT_SOUND_START "buttons/button9.wav" // Not precached
#define STYLE_DEFAULT_SOUND_END "buttons/bell1.wav" // Not precached
#define STYLE_DEFAULT_PERF_TICKS 2
#define STYLE_DEFAULT_PERF_SPEED_CAP 300.0 // Meme

#define STYLE_LEGACY_SOUND_START "buttons/button3.wav" // Not precached
#define STYLE_LEGACY_SOUND_END "buttons/button3.wav" // Not precached
#define STYLE_LEGACY_PERF_TICKS 1
#define STYLE_LEGACY_PERF_SPEED_CAP 380.0
#define STYLE_LEGACY_SPEED_PRESTRAFE_MINIMUM 175.0

#define SOUND_TIMER_FORCE_STOP "buttons/button18.wav" // Not precached
#define SOUND_CHECKPOINT "buttons/blip1.wav" // Not precached
#define SOUND_TELEPORT "buttons/blip1.wav" // Not precached

#define PLAYER_MODEL_ALPHA 100



/*===============================  Global Variables  ===============================*/

/* CS:GO ConVars */
ConVar gCV_DisableImmunityAlpha;
ConVar gCV_FullAlltalk;

/* SimpleKZ ConVars */
ConVar gCV_ChatProcessing;
ConVar gCV_DefaultStyle;
ConVar gCV_PlayerModelT;
ConVar gCV_PlayerModelCT;

/* Menus */
Handle gH_PistolMenu[MAXPLAYERS + 1];
Handle gH_TeleportMenu[MAXPLAYERS + 1];
bool gB_TeleportMenuIsShowing[MAXPLAYERS + 1];
Handle gH_OptionsMenu[MAXPLAYERS + 1];
bool gB_CameFromOptionsMenu[MAXPLAYERS + 1];
Handle gH_MovementStyleMenu[MAXPLAYERS + 1];

/* Movement Tweaker */
MovementPlayer g_MovementPlayer[MAXPLAYERS + 1];
float gF_PrestrafeVelocityModifier[MAXPLAYERS + 1];
bool gB_HitPerf[MAXPLAYERS + 1];
char gC_PlayerModelT[256];
char gC_PlayerModelCT[256];

/* Timer */
bool gB_TimerRunning[MAXPLAYERS + 1];
float gF_CurrentTime[MAXPLAYERS + 1];
bool gB_Paused[MAXPLAYERS + 1];
float gF_LastResumeTime[MAXPLAYERS + 1];
bool gB_HasResumedInThisRun[MAXPLAYERS + 1];
int gI_CurrentCourse[MAXPLAYERS + 1];

/* Options */
KZStyle g_Style[MAXPLAYERS + 1];
KZShowingTeleportMenu g_ShowingTeleportMenu[MAXPLAYERS + 1];
KZShowingInfoPanel g_ShowingInfoPanel[MAXPLAYERS + 1];
KZShowingKeys g_ShowingKeys[MAXPLAYERS + 1];
KZShowingPlayers g_ShowingPlayers[MAXPLAYERS + 1];
KZShowingWeapon g_ShowingWeapon[MAXPLAYERS + 1];
KZAutoRestart g_AutoRestart[MAXPLAYERS + 1];
KZSlayOnEnd g_SlayOnEnd[MAXPLAYERS + 1];
KZPistol g_Pistol[MAXPLAYERS + 1];
KZCheckpointMessages g_CheckpointMessages[MAXPLAYERS + 1];
KZCheckpointSounds g_CheckpointSounds[MAXPLAYERS + 1];
KZTeleportSounds g_TeleportSounds[MAXPLAYERS + 1];
KZTimerText g_TimerText[MAXPLAYERS + 1];

/* Button Press Checking */
int gI_OldButtons[MAXPLAYERS + 1];
Regex gRE_BonusStartButton;
Regex gRE_BonusEndButton;
bool gB_HasStartedThisMap[MAXPLAYERS + 1];
bool gB_HasEndedThisMap[MAXPLAYERS + 1];
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
bool gB_HasSavedPosition[MAXPLAYERS + 1];
float gF_SavedOrigin[MAXPLAYERS + 1][3];
float gF_SavedAngles[MAXPLAYERS + 1][3];

/* Measure */
Handle gH_MeasureMenu[MAXPLAYERS + 1];
int gI_GlowSprite;
bool gB_MeasurePosSet[MAXPLAYERS + 1][2];
float gF_MeasurePos[MAXPLAYERS + 1][2][3];
Handle gH_P2PRed[MAXPLAYERS + 1];
Handle gH_P2PGreen[MAXPLAYERS + 1];

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

/* Pistol Entity Names (entity name | alias | team that buys it) 
	Respective to the KZPistol enumeration. */
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
char gC_RadioCommands[][] = 
{
	"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", 
	"fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", 
	"inposition", "reportingin", "getout", "negative", "enemydown", "compliment", "thanks", "cheer"
};

/* Styles translation phrases for chat messages (respective to KZStyle enum) */
char gC_StylePhrases[view_as<int>(KZStyle)][] = 
{
	"Style - Standard", 
	"Style - Legacy"
};

/* Timer text option phrases */
char gC_TimerTextOptionPhrases[][] = 
{
	"Options Menu - Disabled", 
	"Options Menu - Top", 
	"Options Menu - Bottom"
};



/*===============================  Includes  ===============================*/

#include "simplekz-core/api.sp"
#include "simplekz-core/convars.sp"
#include "simplekz-core/commands.sp"
#include "simplekz-core/infopanel.sp"
#include "simplekz-core/mappingapi.sp"
#include "simplekz-core/menus.sp"
#include "simplekz-core/misc.sp"
#include "simplekz-core/movementtweaker.sp"
#include "simplekz-core/options.sp"
#include "simplekz-core/timer.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNatives();
	RegPluginLibrary("simplekz-core");
	gB_LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart() {
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO) {
		SetFailState("This plugin is only for CS:GO.");
	}
	
	// Translations
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz-core.phrases");
	
	// Setup
	CreateGlobalForwards();
	RegisterConVars();
	AutoExecConfig(true, "simplekz-core", "sourcemod/SimpleKZ");
	RegisterCommands();
	AddCommandListeners();
	
	SetupMovementMethodmaps();
	CompileRegexes();
	CreateMenus();
	
	// Hooks
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("round_start", OnRoundStart, EventHookMode_Pre);
	HookEntityOutput("trigger_multiple", "OnStartTouch", OnTrigMultiStartTouch);
	AddCommandListener(OnSay, "say");
	AddCommandListener(OnSay, "say_team");
	AddNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
	
	if (gB_LateLoad) {
		OnLateLoad();
	}
}

// Handles late loading
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

// Print custom disconnection message
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
		SetDrawViewModel(client, view_as<bool>(g_ShowingWeapon[client])); // Hide weapon
		GivePlayerPistol(client, g_Pistol[client]); // Give player their preferred pistol
		CloseTeleportMenu(client);
	}
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); // Godmode
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true); // No Block
	UpdatePlayerModel(GetClientOfUserId(GetEventInt(event, "userid"))); // Change player model to one that doesn't have landing animation
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, _, _, _, PLAYER_MODEL_ALPHA);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	TimerTick(client);
	UpdateTeleportMenu(client); // Can be moved to a slower timer
	UpdateInfoPanel(client); // Can be moved to a slower timer
	UpdateTimerText(client); // Can be moved to a slower timer
	CheckForTimerButtonPress(client);
	MovementTweakGeneral(g_MovementPlayer[client]);
}

// Process player messages including lower casing commands
public Action OnSay(int client, const char[] command, int argc) {
	if (!GetConVarBool(gCV_ChatProcessing)) {
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
	SetupMap();
	LoadKZConfig();
	// Enforce this ConVar to ensure player transparency works
	SetConVarInt(gCV_DisableImmunityAlpha, 1);
}

// Stop round from ever ending
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason) {
	return Plugin_Handled;
}

// Hide other players
public Action OnSetTransmit(int entity, int client) {
	if (!g_ShowingPlayers[client] && entity != client && entity != GetSpectatedPlayer(client)) {
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

// Force full alltalk on round start, and setup entity hooks
public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	SetConVarInt(gCV_FullAlltalk, 1);
	TimerForceStopAll();
	
	SetupMapEntityHooks();
} 