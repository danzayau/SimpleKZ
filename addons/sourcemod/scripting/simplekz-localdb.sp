#include <sourcemod>

#include <geoip>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

/* Formatted using SPEdit Syntax Reformatter - https://github.com/JulienKluge/Spedit */

public Plugin myinfo = 
{
	name = "Simple KZ Local DB", 
	author = "DanZay", 
	description = "Local database module for SimpleKZ.", 
	version = "0.10.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Global Variables  ===============================*/

/* Database */
Database gH_DB;
bool gB_ConnectedToDB;
DatabaseType g_DBType;
int gI_DBPlayerID[MAXPLAYERS + 1];
int gI_DBCurrentMapID;

/* Other */
KZPlayer g_KZPlayer[MAXPLAYERS + 1];
char gC_CurrentMap[64];
bool gB_LateLoad;



/*===============================  Includes  ===============================*/

/* Global variable includes */
#include "simplekz-localdb/sql.sp"

#include "simplekz-localdb/api.sp"
#include "simplekz-localdb/database.sp"
#include "simplekz-localdb/misc.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNatives();
	RegPluginLibrary("simplekz-localdb");
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
	SetupKZMethodmaps();
	
	LoadTranslations("simplekz-localdb.phrases");
	
	DB_SetupDatabase();
	
	if (gB_LateLoad) {
		OnLateLoad();
	}
}

public void OnAllPluginsLoaded() {
	if (!LibraryExists("simplekz-core")) {
		SetFailState("This plugin requires the SimpleKZ Core plugin.");
	}
}

public void OnLibraryAdded(const char[] name) {
	// Send database info if dependent plugins load late
	if (StrEqual(name, "simplekz-localranks")) {
		if (gB_ConnectedToDB) {
			Call_SimpleKZ_OnDatabaseConnect();
		}
	}
}

// Handles late loading
void OnLateLoad() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientAuthorized(client) && !IsFakeClient(client)) {
			DB_SetupClient(g_KZPlayer[client]);
		}
	}
}



/*===============================  Other Events  ===============================*/

public void SimpleKZ_OnClientSetup(int client) {
	DB_SetupClient(g_KZPlayer[client]);
}

public void OnClientDisconnect(int client) {
	if (!IsFakeClient(client)) {
		DB_SaveOptions(g_KZPlayer[client]);
	}
}

public void OnMapStart() {
	GetMapName();
	DB_SetupMap();
}

public void SimpleKZ_OnTimerEnd(int client, int course, KZStyle style, float time, int teleportsUsed, float theoreticalTime) {
	DB_StoreTime(g_KZPlayer[client], course, style, time, teleportsUsed, theoreticalTime);
} 