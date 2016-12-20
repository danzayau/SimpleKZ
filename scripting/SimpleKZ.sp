#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>


Plugin myinfo = 
{
	name = "Simple KZ", 
	author = "DanZay", 
	description = "A simple KZ plugin with timer.", 
	version = "0.2.1", 
	url = "https://github.com/danzayau/SimpleKZ"
};


// Global Variables
/* 	timer	*/
bool g_clientTimerRunning[MAXPLAYERS + 1] =  { false, ... };
float g_clientStartTime[MAXPLAYERS + 1] =  { 0.0, ... };
float g_clientCurrentTime[MAXPLAYERS + 1] =  { 0.0, ... };
bool g_clientHasStartPosition[MAXPLAYERS + 1] =  { false, ... };
float g_clientStartOrigin[MAXPLAYERS + 1][3];
float g_clientStartAngles[MAXPLAYERS + 1][3];
int g_clientCheckpointsSet[MAXPLAYERS + 1] =  { 0, ... };
int g_clientTeleportsUsed[MAXPLAYERS + 1] =  { 0, ... };
float g_clientCheckpointOrigin[MAXPLAYERS + 1][3];
float g_clientCheckpointAngles[MAXPLAYERS + 1][3];
float g_clientUndoOrigin[MAXPLAYERS + 1][3];
float g_clientUndoAngle[MAXPLAYERS + 1][3];
bool g_clientCanUndo[MAXPLAYERS + 1] =  { false, ... };
/*	timer menu	*/
bool g_clientUsingOtherMenu[MAXPLAYERS + 1] =  { false, ... };
bool g_clientUsingTeleportMenu[MAXPLAYERS + 1] =  { true, ... };
Handle g_timerMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
/*	misc	*/
bool g_clientHidingPlayers[MAXPLAYERS + 1] =  { false, ... };


// Includes
#include "commands.sp"
#include "timer.sp"
#include "timermenu.sp"
#include "misc.sp"


// Functions

public void OnPluginStart() {
	// Check if game is CS:GO.
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO)
	{
		SetFailState("This plugin is for CS:GO.");
	}
	
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
}

public void OnMapStart() {
	LoadKZConfig();
}

public void OnClientPutInServer(client) {
	// Get rid of bots when they join.
	if (IsFakeClient(client)) {
		ServerCommand("bot_quota 0");
	}
	else {
		// Reset all the player's variables
		ResetClientVariables(client);
		TimerMenuSetup(client);
		// Hooks
		SDKHook(client, SDKHook_SetTransmit, OnSetTransmit);
		SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);		
	}
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	// CleanHUD using a timer or else it doesn't work
	CreateTimer(0.0, CleanHUD, client);
	// Godmode
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	// No Block
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
} 

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	// Update variables.
	if (IsValidClient(client)) {
		if (IsPlayerAlive(client)) {
			TimerTick(client);
		}
		UpdateTimerMenu(client);
	}
}

// Stop round from ending
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	return Plugin_Handled;
}

// Hide other players
public Action OnSetTransmit(int entity, int client)
{
	if (IsValidClient(client))
	{
		if (g_clientHidingPlayers[client] && entity != client && entity != GetSpectatedPlayer(client)) {
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

// Remove dropped weapons
public Action OnWeaponDrop(int client, int weapon) {
	if (IsValidEntity(weapon))
		AcceptEntityInput(weapon, "Kill");
}

// Stop menu from overlapping the mapvote
public void OnMapVoteStarted()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client)) {
			g_clientUsingOtherMenu[client] = true;
		}
	}
}

// Stop menu from overlapping other menus by using command listeners
public Action CommandOpenOtherMenu(int client, const char[] command, int argc) {
	if (IsValidClient(client)) {
		g_clientUsingOtherMenu[client] = true;
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