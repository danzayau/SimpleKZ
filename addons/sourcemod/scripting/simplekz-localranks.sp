#include <sourcemod>
#include <sdktools>
#include <cstrike>

#include <colorvariables>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

/* Formatted using SPEdit Syntax Reformatter - https://github.com/JulienKluge/Spedit */

public Plugin myinfo = 
{
	name = "Simple KZ Ranks", 
	author = "DanZay", 
	description = "Local ranks module for SimpleKZ.", 
	version = "0.10.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Definitions  ===============================*/

#define FILE_PATH_MAPPOOL "cfg/sourcemod/SimpleKZ/mappool.cfg"

// TO-DO: Replace with sound config
#define FULL_SOUNDPATH_BEAT_RECORD "sound/SimpleKZ/beatrecord1.mp3"
#define REL_SOUNDPATH_BEAT_RECORD "*/SimpleKZ/beatrecord1.mp3"
#define FULL_SOUNDPATH_BEAT_MAP "sound/SimpleKZ/beatmap1.mp3"
#define REL_SOUNDPATH_BEAT_MAP "*/SimpleKZ/beatmap1.mp3"



/*===============================  Global Variables  ===============================*/

/* Database */
Database gH_DB = null;
bool gB_ConnectedToDB = false;
DatabaseType g_DBType = DatabaseType_None;

/* Menus */
Handle gH_MapTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_MapTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
char gC_MapTopMapName[MAXPLAYERS + 1][64];
int gI_MapTopMapID[MAXPLAYERS + 1];
int gI_MapTopCourse[MAXPLAYERS + 1];
KZStyle g_MapTopStyle[MAXPLAYERS + 1];
Handle gH_PlayerTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_PlayerTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
KZStyle g_PlayerTopStyle[MAXPLAYERS + 1];

/* Other */
bool gB_LateLoad;

/* Styles translation phrases for chat messages (respective to KZStyle enum) */
char gC_StylePhrases[view_as<int>(KZStyle)][] = 
{ "Style - Standard", 
	"Style - Legacy"
};

/* Time type translation phrases for chat messages (respective to KZTimeType enum) */
char gC_TimeTypePhrases[view_as<int>(KZTimeType)][] = 
{ "Time Type - Normal", 
	"Time Type - Pro", 
	"Time Type - Theoretical"
};



/*===============================  Includes  ===============================*/

/* Global variable includes */
#include "simplekz-localranks/sql.sp"

#include "simplekz-localranks/api.sp"
#include "simplekz-localranks/commands.sp"
#include "simplekz-localranks/database.sp"
#include "simplekz-localranks/menus.sp"
#include "simplekz-localranks/misc.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	RegPluginLibrary("simplekz-localranks");
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
	RegisterCommands();
	
	// Translations
	LoadTranslations("simplekz-core.phrases");
	LoadTranslations("simplekz-localdb.phrases");
	LoadTranslations("simplekz-localranks.phrases");
	
	CreateMenus();
	
	if (gB_LateLoad) {
		OnLateLoad();
	}
}

public void OnAllPluginsLoaded() {
	if (!LibraryExists("simplekz-core")) {
		SetFailState("This plugin requires the SimpleKZ Core plugin.");
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



/*===============================  Client and Map Events  ===============================*/

public void OnClientAuthorized(int client, const char[] auth) {
	// Prepare for client arrival
	if (!IsFakeClient(client)) {
		SetupClient(client);
	}
}

public void OnClientPutInServer(int client) {
	if (!IsFakeClient(client)) {
		UpdateCompletionMVPStars(client);
	}
}

public void OnMapStart() {
	// Add files to download table
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_RECORD);
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_MAP);
	
	// Precache stuff
	FakePrecacheSound(REL_SOUNDPATH_BEAT_RECORD);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_MAP);
}



/*===============================  SimpleKZ Events  ===============================*/

public void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType) {
	gB_ConnectedToDB = true;
	gH_DB = database;
	g_DBType = DBType;
	DB_CreateTables();
}

public void SimpleKZ_OnStoreTimeInDB(int client, int playerID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS) {
	DB_ProcessNewTime(client, playerID, mapID, course, style, runTimeMS, teleportsUsed);
}

public void SimpleKZ_OnNewRecord(int client, int mapID, int course, KZStyle style, KZRecordType recordType, float runTime) {
	if (mapID == SimpleKZ_GetCurrentMapID()) {
		AnnounceNewRecord(client, course, style, recordType);
	}
}

public void SimpleKZ_OnNewPersonalBest(int client, int mapID, int course, KZStyle style, KZTimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank) {
	if (mapID == SimpleKZ_GetCurrentMapID() && rank != 1) {
		AnnounceNewPersonalBest(client, course, style, timeType, firstTime, improvement, rank, maxRank);
	}
} 