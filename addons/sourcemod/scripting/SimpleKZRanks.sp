#include <sourcemod>
#include <sdktools>
#include <cstrike>

#include <colorvariables>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Simple KZ Ranks", 
	author = "DanZay", 
	description = "Player ranks module for SimpleKZ.", 
	version = "0.8.1", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Definitions  ===============================*/

#define MAPPOOL_FILE_PATH "cfg/sourcemod/SimpleKZ/mappool.cfg"

// TO-DO: Replace with sound config
#define FULL_SOUNDPATH_BEAT_RECORD "sound/SimpleKZ/beatrecord1.mp3"
#define REL_SOUNDPATH_BEAT_RECORD "*/SimpleKZ/beatrecord1.mp3"
#define FULL_SOUNDPATH_BEAT_MAP "sound/SimpleKZ/beatmap1.mp3"
#define REL_SOUNDPATH_BEAT_MAP "*/SimpleKZ/beatmap1.mp3"



/*===============================  Global Variables  ===============================*/

bool gB_LateLoad;

char gC_CurrentMap[64];
char gC_SteamID[MAXPLAYERS + 1][24];

// Database
Database gH_DB = null;
bool gB_ConnectedToDB = false;
DatabaseType g_DBType = DatabaseType_None;

// Menus
char gC_MapTopMap[MAXPLAYERS + 1][64];
Handle gH_MapTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_MapTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_PlayerTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_PlayerTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };



/*===============================  Includes  ===============================*/

// Global Variable Includes
#include "SimpleKZRanks/sql.sp"

#include "SimpleKZRanks/api.sp"
#include "SimpleKZRanks/commands.sp"
#include "SimpleKZRanks/database.sp"
#include "SimpleKZRanks/menus.sp"
#include "SimpleKZRanks/misc.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	RegPluginLibrary("SimpleKZRanks");
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
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz.phrases");
	
	CreateMenus();
	
	if (gB_LateLoad) {
		OnLateLoad();
	}
}

public void OnAllPluginsLoaded() {
	if (!LibraryExists("SimpleKZ")) {
		SetFailState("This plugin requires the SimpleKZ core plugin.");
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



/*===============================  SimpleKZ Events  ===============================*/

public void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType) {
	gB_ConnectedToDB = true;
	gH_DB = database;
	g_DBType = DBType;
	DB_CreateTables();
}

public void SimpleKZ_OnTimerStarted(int client, bool firstStart) {
	if (firstStart && gB_ConnectedToDB) {
		DB_PrintPBs(client, client, gC_CurrentMap);
	}
}

public void SimpleKZ_OnTimerEnded(int client, float time, int teleportsUsed, float theoreticalTime) {
	DB_ProcessEndTimer(client, gC_CurrentMap, time, teleportsUsed, theoreticalTime);
}

public void SimpleKZ_OnBeatMapRecord(int client, const char[] map, RecordType recordType, float runTime) {
	switch (recordType) {
		case RecordType_Map: {
			CPrintToChatAll(" %t", "BeatMapRecord", client);
		}
		case RecordType_Pro: {
			CPrintToChatAll(" %t", "BeatProRecord", client);
		}
		case RecordType_MapAndPro: {
			CPrintToChatAll(" %t", "BeatMapAndProRecord", client);
		}
	}
	EmitSoundToAll(REL_SOUNDPATH_BEAT_RECORD);
}

public void SimpleKZ_OnBeatMapFirstTime(int client, const char[] map, RunType runType, float runTime, int rank, int maxRank) {
	if (rank == 1) {
		return;
	}
	switch (runType) {
		case RunType_Normal: {
			CPrintToChatAll(" %t", "BeatMapFirstTime", client, rank, maxRank);
		}
		case RunType_Pro: {
			CPrintToChatAll(" %t", "BeatMapFirstTime_Pro", client, rank, maxRank);
			EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
			EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
		}
	}
}

public void SimpleKZ_OnImproveTime(int client, const char[] map, RunType runType, float runTime, float improvement, int rank, int maxRank) {
	if (rank == 1) {
		return;
	}
	switch (runType) {
		case RunType_Normal: {
			CPrintToChatAll(" %t", "ImprovedTime", client, FormatTimeFloat(improvement), rank, maxRank);
		}
		case RunType_Pro: {
			CPrintToChatAll(" %t", "ImprovedTime_Pro", client, FormatTimeFloat(improvement), rank, maxRank);
		}
	}
}



/*===============================  Miscellaneous Events  ===============================*/

public void OnClientAuthorized(int client, const char[] auth) {
	if (!IsFakeClient(client)) {
		SetupClient(client);
	}
}

public void OnClientPutInServer(int client) {
	if (!IsFakeClient(client)) {
		DB_GetCompletion(client, client, false);
	}
}

public void OnMapStart() {
	UpdateCurrentMap();
	DB_SaveMapInfo();
	
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_RECORD);
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_MAP);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_RECORD);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_MAP);
} 