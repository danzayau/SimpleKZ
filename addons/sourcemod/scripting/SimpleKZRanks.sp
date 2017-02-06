#include <sourcemod>
#include <sdktools>

#include <colorvariables>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Simple KZ Ranks", 
	author = "DanZay", 
	description = "Player ranks module for SimpleKZ.", 
	version = "0.7.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Global Variables  ===============================*/

// Database
Database gH_DB = null;
bool gB_ConnectedToDB = false;
DatabaseType g_DBType = NONE;
char gC_CurrentMap[64];
char gC_SteamID[MAXPLAYERS + 1][24];

// Menus
Handle gH_MapTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
char gC_MapTopMap[MAXPLAYERS + 1][64];
Handle gH_MapTopSubmenu[MAXPLAYERS + 1] = INVALID_HANDLE;



/*===============================  Includes  ===============================*/

// Global Variable Includes
#include "SimpleKZRanks/sql.sp"

#include "SimpleKZRanks/commands.sp"
#include "SimpleKZRanks/database.sp"
#include "SimpleKZRanks/menus.sp"
#include "SimpleKZRanks/misc.sp"
#include "SimpleKZRanks/api.sp"



/*===============================  Plugin Events  ===============================*/

public void OnPluginStart() {
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO) {
		SetFailState("This plugin is only for CS:GO.");
	}
	
	CreateGlobalForwards();
	RegisterCommands();
	
	// Translations
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz.phrases");
	
	CreateMenus();
}

public void OnAllPluginsLoaded() {
	if (!LibraryExists("SimpleKZ")) {
		SetFailState("This plugin requires the SimpleKZ core plugin.");
	}
}

public void OnLibraryRemoved(const char[] name) {
	if (StrEqual(name, "SimpleKZ")) {
		SetFailState("This plugin requires the SimpleKZ core plugin.");
	}
}



/*===============================  Miscellaneous Events  ===============================*/

public void OnClientAuthorized(int client) {
	if (!IsFakeClient(client)) {
		GetClientSteamID(client);
		
		UpdateMapTopMenu(client);
	}
}

public void OnMapStart() {
	UpdateCurrentMap();
	DB_SaveMapInfo();
	
	FakePrecacheSound("*/commander/commander_comment_01.wav");
	FakePrecacheSound("*/commander/commander_comment_02.wav");
	FakePrecacheSound("*/commander/commander_comment_05.wav");
}

public void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType) {
	gB_ConnectedToDB = true;
	gH_DB = database;
	g_DBType = DBType;
	DB_CreateTables();
}

public void SimpleKZ_OnTimerStarted(int client, const char[] map, bool firstStart) {
	if (firstStart) {
		DB_PrintPBs(client, client, map);
	}
}

public void SimpleKZ_OnTimerEnded(int client, const char[] map, float time, int teleportsUsed, float theoreticalTime) {
	DB_ProcessEndTimer(client, map, time, teleportsUsed, theoreticalTime);
} 