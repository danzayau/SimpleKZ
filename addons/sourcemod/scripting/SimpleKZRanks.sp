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
	description = "Player ranks module for SimpleKZ (local/non-global).", 
	version = "0.9.0", 
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
char gC_MapTopMap[MAXPLAYERS + 1][64];
MovementStyle g_MapTopStyle[MAXPLAYERS + 1];
Handle gH_MapTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_MapTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_PlayerTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
MovementStyle g_PlayerTopStyle[MAXPLAYERS + 1];
Handle gH_PlayerTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };

/* Other */
bool gB_LateLoad;
bool gB_HasSeenPBs[MAXPLAYERS + 1];

// Styles translation phrases for chat messages (respective to MovementStyle enum)
char gC_StyleChatPhrases[SIMPLEKZ_NUMBER_OF_STYLES][] = 
{ "Style_Standard", 
	"Style_Legacy"
};

// Styles translation phrases for menus (respective to MovementStyle enum)
char gC_StyleMenuPhrases[SIMPLEKZ_NUMBER_OF_STYLES][] = 
{ "StyleMenu_Standard", 
	"StyleMenu_Legacy"
};



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
	LoadTranslations("simplekzranks.phrases");
	
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

public void SimpleKZ_OnTimerStart(int client, const char[] map, int course, MovementStyle style) {
	if (gB_ConnectedToDB && !gB_HasSeenPBs[client] && course == 0) {
		DB_PrintPBs(client, client, map, style);
	}
}

public void SimpleKZ_OnTimerEnd(int client, const char[] map, int course, MovementStyle style, float time, int teleportsUsed, float theoreticalTime) {
	if (course == 0) {
		DB_ProcessEndTimer(client, map, style, time, teleportsUsed, theoreticalTime);
	}
}

public void SimpleKZ_OnChangeMovementStyle(int client, MovementStyle newStyle) {
	gB_HasSeenPBs[client] = false;
}

public void SimpleKZ_OnBeatMapRecord(int client, const char[] map, MovementStyle style, RecordType recordType, float runTime) {
	switch (recordType) {
		case RecordType_Map: {
			CPrintToChatAll(" %t", "BeatMapRecord", client, gC_StyleChatPhrases[style]);
		}
		case RecordType_Pro: {
			CPrintToChatAll(" %t", "BeatProRecord", client, gC_StyleChatPhrases[style]);
		}
		case RecordType_MapAndPro: {
			CPrintToChatAll(" %t", "BeatMapAndProRecord", client, gC_StyleChatPhrases[style]);
		}
	}
	EmitSoundToAll(REL_SOUNDPATH_BEAT_RECORD);
}

public void SimpleKZ_OnBeatMapFirstTime(int client, const char[] map, MovementStyle style, RunType runType, float runTime, int rank, int maxRank) {
	if (rank == 1) {
		return;
	}
	switch (runType) {
		case RunType_Normal: {
			// Only printing MAP time improvement to the achieving player due to spam complaints
			CPrintToChat(client, " %t", "BeatMapFirstTime", client, rank, maxRank, gC_StyleChatPhrases[style]);
		}
		case RunType_Pro: {
			CPrintToChatAll(" %t", "BeatMapFirstTime_Pro", client, rank, maxRank, gC_StyleChatPhrases[style]);
			EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
			EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
		}
	}
}

public void SimpleKZ_OnImproveTime(int client, const char[] map, MovementStyle style, RunType runType, float runTime, float improvement, int rank, int maxRank) {
	if (rank == 1) {
		return;
	}
	switch (runType) {
		case RunType_Normal: {
			// Only printing MAP time improvement to the achieving player due to spam complaints
			CPrintToChat(client, " %t", "ImprovedTime", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StyleChatPhrases[style]);
		}
		case RunType_Pro: {
			CPrintToChatAll(" %t", "ImprovedTime_Pro", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StyleChatPhrases[style]);
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
		DB_GetCompletion(client, client, SimpleKZ_GetMovementStyle(client), false);
	}
}

public void OnMapStart() {
	DB_SaveMapInfo();
	
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_RECORD);
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_MAP);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_RECORD);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_MAP);
} 