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
	version = "0.3", 
	url = "https://github.com/danzayau/SimpleKZ"
};


// Global Variables
MovementPlayer g_MovementPlayer[MAXPLAYERS + 1];
/* 	timer		*/
bool gB_TimerRunning[MAXPLAYERS + 1];

float gF_StartTime[MAXPLAYERS + 1];
float gF_CurrentTime[MAXPLAYERS + 1];

bool gB_HasStartPosition[MAXPLAYERS + 1];
float gF_StartOrigin[MAXPLAYERS + 1][3];
float gF_StartAngles[MAXPLAYERS + 1][3];

int gI_CheckpointsSet[MAXPLAYERS + 1];
int gI_TeleportsUsed[MAXPLAYERS + 1];
float gF_CheckpointOrigin[MAXPLAYERS + 1][3];
float gF_CheckpointAngles[MAXPLAYERS + 1][3];

bool gB_CanUndo[MAXPLAYERS + 1];
float gF_UndoOrigin[MAXPLAYERS + 1][3];
float gF_UndoAngle[MAXPLAYERS + 1][3];

float gF_CheckpointTime[MAXPLAYERS + 1];
float gF_TeleportTime[MAXPLAYERS + 1];
float gF_UndoTime[MAXPLAYERS + 1];
float gF_WastedTime[MAXPLAYERS + 1];

/*	timer menu	*/
bool gB_UsingOtherMenu[MAXPLAYERS + 1];
bool gB_UsingTeleportMenu[MAXPLAYERS + 1];
Handle gH_TimerMenu[MAXPLAYERS + 1];

/*	infopanel	*/
bool gB_InfoPanel[MAXPLAYERS + 1];

/*	misc		*/
bool gB_HidingPlayers[MAXPLAYERS + 1];
bool gB_HidingWeapon[MAXPLAYERS + 1];

/*	sql			*/
//Database gDB_database = INVALID_HANDLE;


// Includes
#include "commands.sp"
#include "timer.sp"
#include "timermenu.sp"
#include "infopanel.sp"
#include "misc.sp"
#include "api.sp"


// Functions

public void OnPluginStart() {
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO)
	{
		SetFailState("This plugin is for CS:GO.");
	}
	
	// Forwards
	CreateGlobalForwards();
	
	// Commands
	RegisterCommands();
	
	// Command Listeners
	AddCommandListeners();
	
	// Menus
	TimerMenuSetupAll();
	
	// Hooks
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEntityOutput("func_button", "OnPressed", ButtonPress);
	
	// Translations
	LoadTranslations("common.phrases");
	
	// Setup Movement API Methodmaps
	for (int client = 1; client <= MaxClients; client++) {
		g_MovementPlayer[client] = new MovementPlayer(client);
	}
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
		gB_InfoPanel[client] = true;
		gB_HidingWeapon[client] = false;
		TimerSetupVariables(client);
		TimerMenuSetup(client);
		// Hooks
		SDKHook(client, SDKHook_SetTransmit, OnSetTransmit);
		SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	}
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	// Clean HUD (using a timer or else it doesn't work)
	CreateTimer(0.0, CleanHUD, client);
	// Godmode
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	// No Block
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
	// Hide weapon
	SetDrawViewModel(client, !gB_HidingWeapon[client]);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	// Update variables
	if (IsValidClient(client)) {
		if (IsPlayerAlive(client)) {
			TimerTick(client);
		}
		UpdateTimerMenu(client);
		UpdateInfoPanel(g_MovementPlayer[client]);
	}
}

// Stop round from ever ending
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	return Plugin_Handled;
}

// Hide other players
public Action OnSetTransmit(int entity, int client)
{
	if (IsValidClient(client))
	{
		if (gB_HidingPlayers[client] && entity != client && entity != GetSpectatedPlayer(client)) {
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

// Remove dropped weapons
public Action OnWeaponDrop(int client, int weapon) {
	if (IsValidEntity(weapon)) {
		AcceptEntityInput(weapon, "Kill");
	}
}

// Stop menu from overlapping the mapvote
public void OnMapVoteStarted()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client)) {
			gB_UsingOtherMenu[client] = true;
		}
	}
}

// Stop menu from overlapping other menus by using command listeners
public Action CommandOpenOtherMenu(int client, const char[] command, int argc) {
	if (IsValidClient(client)) {
		gB_UsingOtherMenu[client] = true;
	}
}

// Allow unlimited team changes
public Action CommandJoinTeam(int client, const char[] command, int argc) {
	if (IsValidClient(client)) {
		char teamString[4];
		GetCmdArgString(teamString, sizeof(teamString));
		int team = StringToInt(teamString);
		
		if (1 <= team <= 3) {
			ChangeClientTeam(client, team);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
} 