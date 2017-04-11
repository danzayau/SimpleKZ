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



/*===============================  Definitions  ===============================*/

#define TIME_PAUSE_COOLDOWN 1.0
#define TIME_SPLIT_COOLDOWN 1.0
#define TIME_BHOP_TRIGGER_DETECTION 0.2 // Time after touching trigger_multiple to block checkpoints
#define DISTANCE_BUTTON_PRESS_CHECK 40.0 // Max distance from saved press position to detect a press

#define SPEED_NORMAL 250.0
#define SPEED_NO_WEAPON 260.0
#define PRESTRAFE_VELMOD_MAX 1.104 // Calculated 276/250
#define PRESTRAFE_VELMOD_INCREMENT 0.0014 // Per tick when prestrafing
#define PRESTRAFE_VELMOD_DECREMENT 0.0021 // Per tick when not prestrafing
#define VELOCITY_VERTICAL_NORMAL_JUMP 292.54 // After one tick after jumping
#define DUCK_SPEED_MINIMUM 7.0

#define STYLE_DEFAULT_SOUND_START "buttons/button9.wav"
#define STYLE_DEFAULT_SOUND_END "buttons/bell1.wav"
#define STYLE_DEFAULT_PERF_TICKS 2

#define STYLE_LEGACY_SOUND_START "buttons/button3.wav"
#define STYLE_LEGACY_SOUND_END "buttons/button3.wav"
#define STYLE_LEGACY_PERF_TICKS 1
#define STYLE_LEGACY_PERF_SPEED_CAP 380.0
#define STYLE_LEGACY_SPEED_PRESTRAFE_MINIMUM 175.0

#define SOUND_TIMER_FORCE_STOP "buttons/button18.wav"
#define SOUND_CHECKPOINT "buttons/blip1.wav"
#define SOUND_TELEPORT "buttons/blip1.wav"

#define PLAYER_MODEL_ALPHA 100



/*===============================  Global Variables  ===============================*/

public Plugin myinfo =  {
	name = "Simple KZ Core", 
	author = "DanZay", 
	description = "A simple KZ timer plugin.", 
	version = "0.11.0-dev", 
	url = "https://github.com/danzayau/SimpleKZ"
};

/* CS:GO ConVars */
ConVar gCV_DisableImmunityAlpha;
ConVar gCV_FullAlltalk;

/* SimpleKZ ConVars */
ConVar gCV_ChatProcessing;
ConVar gCV_DefaultStyle;
ConVar gCV_PlayerModelT;
ConVar gCV_PlayerModelCT;

/* Menus */
Menu gH_MeasureMenu[MAXPLAYERS + 1];
Menu g_OptionsMenu[MAXPLAYERS + 1];
bool gB_CameFromOptionsMenu[MAXPLAYERS + 1];
Menu g_PistolMenu[MAXPLAYERS + 1];
Menu g_StyleMenu[MAXPLAYERS + 1];
Menu g_TPMenu[MAXPLAYERS + 1];
bool gB_TPMenuIsShowing[MAXPLAYERS + 1];

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
KZShowingTPMenu g_ShowingTPMenu[MAXPLAYERS + 1];
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
{
	"weapon_ak47", "weapon_aug", "weapon_awp", "weapon_bizon", "weapon_deagle", 
	"weapon_decoy", "weapon_elite", "weapon_famas", "weapon_fiveseven", "weapon_flashbang", 
	"weapon_g3sg1", "weapon_galilar", "weapon_glock", "weapon_hegrenade", "weapon_hkp2000", 
	"weapon_incgrenade", "weapon_knife", "weapon_m249", "weapon_m4a1", "weapon_mac10", 
	"weapon_mag7", "weapon_molotov", "weapon_mp7", "weapon_mp9", "weapon_negev", 
	"weapon_nova", "weapon_p250", "weapon_p90", "weapon_sawedoff", "weapon_scar20", 
	"weapon_sg556", "weapon_smokegrenade", "weapon_ssg08", "weapon_taser", "weapon_tec9", 
	"weapon_ump45", "weapon_xm1014"
};

/* Max movement speed of weapons (respective to gC_WeaponNames). */
int gI_WeaponRunSpeeds[] = 
{
	215, 220, 200, 240, 230, 
	245, 240, 220, 240, 245, 
	215, 215, 240, 245, 240, 
	245, 250, 195, 225, 240, 
	225, 245, 220, 240, 195, 
	220, 240, 230, 210, 215, 
	210, 245, 230, 240, 240, 
	230, 215
};

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
	"fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", 
	"needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", 
	"enemydown", "compliment", "thanks", "cheer"
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
#include "simplekz-core/commands.sp"
#include "simplekz-core/convars.sp"
#include "simplekz-core/hud.sp"
#include "simplekz-core/mapping_api.sp"
#include "simplekz-core/menus.sp"
#include "simplekz-core/misc.sp"
#include "simplekz-core/movementtweaker.sp"
#include "simplekz-core/options.sp"
#include "simplekz-core/timer.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("simplekz-core");
	gB_LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO)
	{
		SetFailState("This plugin is only for CS:GO.");
	}
	
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz-core.phrases");
	
	CreateMovementPlayers();
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
		if (IsClientConnected(client))
		{
			OnClientConnected(client);
		}
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
		}
	}
}



/*===============================  Client Events  ===============================*/

public void OnClientConnected(int client)
{
	if (!IsFakeClient(client))
	{
		SetupClient(client);
	}
}

public void OnClientPutInServer(int client)
{
	if (!IsFakeClient(client))
	{
		SDKHook(client, SDKHook_SetTransmit, OnSetTransmit);
		PrintConnectMessage(client);
	}
}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	// Print custom disconnection message
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		SetEventBroadcast(event, true);
		char reason[64];
		GetEventString(event, "reason", reason, sizeof(reason));
		PrintDisconnectMessage(client, reason);
	}
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client))
	{
		CreateTimer(0.0, CleanHUD, client); // Using 1 tick timer or else it won't work
		UpdateWeaponVisibility(client);
		UpdatePlayerPistol(client);
		CloseTPMenu(client);
	}
	UpdatePlayerModel(client);
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); // Godmode
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true); // No player blocking
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, _, _, _, PLAYER_MODEL_ALPHA);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	UpdateTimer(client);
	CheckForTimerButtonPress(client);
	TweakMovementGeneral(g_MovementPlayer[client]);
	
	// These don't necessarily need to be updated every tick
	UpdateTPMenu(client);
	UpdateInfoPanel(client);
	UpdateTimerText(client);
}

public Action OnSay(int client, const char[] command, int argc)
{
	// Process player messages including lower casing commands
	if (!GetConVarBool(gCV_ChatProcessing))
	{
		return Plugin_Continue;
	}
	
	if (BaseComm_IsClientGagged(client))
	{
		return Plugin_Handled;
	}
	
	char message[128];
	GetCmdArgString(message, sizeof(message));
	StripQuotes(message);
	
	// Change to lower case (potential) command messages
	if ((message[0] == '/' || message[0] == '!') && IsCharUpper(message[1]))
	{
		for (int i = 1; i <= strlen(message); i++)
		{
			message[i] = CharToLower(message[i]);
		}
		FakeClientCommand(client, "say %s", message);
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
		CPrintToChatAll("{bluegrey}%N{default} : %s", client, message);
	}
	else
	{
		CPrintToChatAll("{lime}%N{default} : %s", client, message);
	}
	return Plugin_Handled;
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client))
	{
		TimerForceStop(client);
	}
}



/*===============================  Movement API Events  ===============================*/

public void OnStartTouchGround(int client)
{
	TweakMovementDuckSlowdown(g_MovementPlayer[client]);
}

public void OnStopTouchGround(int client, bool jumped, bool ducked, bool landed)
{
	if (jumped)
	{
		TweakMovementTakeoffSpeed(g_MovementPlayer[client]);
		if (g_Style[client] == KZStyle_Standard && ducked)
		{
			TweakMovementPerfectCrouchJump(g_MovementPlayer[client]);
		}
	}
	else
	{
		gB_HitPerf[client] = false; // Not a jump so not a perf
	}
	
	if (g_Style[client] == KZStyle_Standard)
	{
		gF_PrestrafeVelocityModifier[client] = 1.0; // No 'pre b-hopping' in Standard
	}
}

public void OnStopTouchLadder(int client)
{
	gB_HitPerf[client] = false;
}

public void OnStartNoclipping(int client)
{
	if (!IsFakeClient(client))
	{
		gB_Paused[client] = false; // Player forcefully left paused state by noclipping
		if (TimerForceStop(client))
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped (Noclipped)");
		}
	}
}

public void OnStopNoclipping(int client)
{
	gB_HitPerf[client] = false;
}



/*===============================  Miscellaneous Events  ===============================*/

public void OnMapStart()
{
	SetupMap();
	ExecuteKZConfig();
	SetConVarInt(gCV_DisableImmunityAlpha, 1); // Ensures player transparency works
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	return Plugin_Handled; // Stop round from ever ending
}

public Action OnSetTransmit(int entity, int client)
{
	if (g_ShowingPlayers[client] == KZShowingPlayers_Disabled && entity != client && entity != GetSpectatedClient(client))
	{
		return Plugin_Handled; // Hides other players
	}
	return Plugin_Continue;
}

public Action OnPlayerJoinTeam(Event event, const char[] name, bool dontBroadcast)
{
	SetEventBroadcast(event, true); // Block join team messages
	return Plugin_Continue;
}

public Action OnNormalSound(int[] clients, int &numClients, char[] sample, int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char[] soundEntry, int &seed)
{
	char className[20];
	GetEntityClassname(entity, className, sizeof(className));
	if (StrEqual(className, "func_button", false))
	{
		return Plugin_Handled; // No sounds directly from func_button
	}
	return Plugin_Continue;
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	SetConVarInt(gCV_FullAlltalk, 1); // Force full alltalk
	TimerForceStopAll();
	SetupMapEntityHooks();
} 