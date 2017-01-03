#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <movement>
#include <movementtweaker>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

Plugin myinfo = 
{
	name = "Simple KZ", 
	author = "DanZay", 
	description = "A simple KZ plugin with timer.", 
	version = "0.3.1", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*=====  Definitions  ======*/

#define MYSQL 0
#define SQLITE 1
#define NUMBER_OF_PISTOLS 9
#define USP_PISTOL_NUMBER 2



/*=====  Global Variables  ======*/

MovementPlayer g_MovementPlayer[MAXPLAYERS + 1];

bool gB_TimerRunning[MAXPLAYERS + 1];
bool gB_Paused[MAXPLAYERS + 1];
float gF_CurrentTime[MAXPLAYERS + 1];

bool gB_HasStartPosition[MAXPLAYERS + 1];
float gF_StartOrigin[MAXPLAYERS + 1][3];
float gF_StartAngles[MAXPLAYERS + 1][3];

int gI_CheckpointsSet[MAXPLAYERS + 1];
int gI_TeleportsUsed[MAXPLAYERS + 1];
float gF_CheckpointOrigin[MAXPLAYERS + 1][3];
float gF_CheckpointAngles[MAXPLAYERS + 1][3];

bool gB_LastTeleportOnGround[MAXPLAYERS + 1];
float gF_UndoOrigin[MAXPLAYERS + 1][3];
float gF_UndoAngle[MAXPLAYERS + 1][3];

float gF_CheckpointTime[MAXPLAYERS + 1];
float gF_TeleportTime[MAXPLAYERS + 1];
float gF_WastedTime[MAXPLAYERS + 1];

bool gB_UsingOtherMenu[MAXPLAYERS + 1];
bool gB_UsingTeleportMenu[MAXPLAYERS + 1];
bool gB_NeedToRefreshTeleportMenu[MAXPLAYERS + 1];
Handle gH_TeleportMenu[MAXPLAYERS + 1];

bool gB_UsingInfoPanel[MAXPLAYERS + 1];

bool gB_HidingPlayers[MAXPLAYERS + 1];
bool gB_HidingWeapon[MAXPLAYERS + 1];

int gI_Pistol[MAXPLAYERS + 1];
Handle gH_PistolMenu;

//Database gDB_database;



/*=====  Includes  ======*/

#include "SimpleKZ/commands.sp"
#include "SimpleKZ/timer.sp"
#include "SimpleKZ/infopanel.sp"
#include "SimpleKZ/misc.sp"
#include "SimpleKZ/api.sp"



/*=====  Events  ======*/

public void OnPluginStart() {
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO) {
		SetFailState("This plugin is for CS:GO.");
	}
	
	CreateGlobalForwards();
	CreateNatives();
	RegisterCommands();
	AddCommandListeners();
	// Hooks
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerTeam, EventHookMode_Pre);
	HookEntityOutput("func_button", "OnPressed", OnButtonPress);
	// Translations
	LoadTranslations("common.phrases");
	
	for (int client = 1; client <= MaxClients; client++) {
		SetupTeleportMenu(client);
		// Setup Global Movement API Methodmaps
		g_MovementPlayer[client] = new MovementPlayer(client);
	}
	SetupPistolMenu();
}

public void OnMapStart() {
	LoadKZConfig();
}

public void OnClientPutInServer(int client) {
	// Get rid of bots when they join
	if (IsFakeClient(client)) {
		ServerCommand("bot_quota 0");
	}
	else {
		// Reset all the player's variables
		//LoadClientOptions(client);
		gB_UsingTeleportMenu[client] = true;
		gB_UsingInfoPanel[client] = true;
		gB_HidingWeapon[client] = false;
		gI_Pistol[client] = 0;
		TimerSetupVariables(client);
		SetupTeleportMenu(client);
		// Hooks
		SDKHook(client, SDKHook_SetTransmit, OnSetTransmit);
	}
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.0, CleanHUD, client); // Clean HUD (using a 1 frame timer or else it won't work)
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); // Godmode
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true); // No Block
	SetDrawViewModel(client, !gB_HidingWeapon[client]); // Hide weapon
	GivePlayerPistol(client, gI_Pistol[client]); // Give player their preffered pistol
}

public Action OnPlayerTeam(Event event, const char[] name, bool dontBroadcast) {
	SetEventBroadcast(event, true);
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	TimerTick(client);
	UpdateTeleportMenu(client);
	UpdateInfoPanel(client);
}

// Stop round from ever ending
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason) {
	return Plugin_Handled;
}

// Hide other players
public Action OnSetTransmit(int entity, int client) {
	if (gB_HidingPlayers[client] && entity != client && entity != GetSpectatedPlayer(client)) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

// Allow unlimited team changes
public Action CommandJoinTeam(int client, const char[] command, int argc) {
	char teamString[4];
	GetCmdArgString(teamString, sizeof(teamString));
	int team = StringToInt(teamString);
	
	if (1 <= team <= 3) {
		ChangeClientTeam(client, team);
		return Plugin_Handled;
	}
	return Plugin_Continue;
} 