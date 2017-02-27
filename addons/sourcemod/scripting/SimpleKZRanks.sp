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
int gI_CurrentMapID;

/* Menus */
Handle gH_MapTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_MapTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
char gC_MapTopMapName[MAXPLAYERS + 1][64];
int gI_MapTopMapID[MAXPLAYERS + 1];
int gI_MapTopCourse[MAXPLAYERS + 1];
MovementStyle g_MapTopStyle[MAXPLAYERS + 1];
Handle gH_PlayerTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_PlayerTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
MovementStyle g_PlayerTopStyle[MAXPLAYERS + 1];

/* Other */
bool gB_LateLoad;
char gC_CurrentMap[64];

/* Styles translation phrases for chat messages (respective to MovementStyle enum) */
char gC_StylePhrases[SIMPLEKZ_NUMBER_OF_STYLES][] = 
{ "Style - Standard", 
	"Style - Legacy"
};

/* Time type translation phrases for chat messages (respective to TimeType enum) */
char gC_TimeTypePhrases[SIMPLEKZ_NUMBER_OF_TIME_TYPES][] = 
{ "Time Type - Normal", 
	"Time Type - Pro", 
	"Time Type - Theoretical"
};



/*===============================  Includes  ===============================*/

/* Global variable includes */
#include "SimpleKZRanks/sql.sp"

#include "SimpleKZRanks/api.sp"
#include "SimpleKZRanks/commands.sp"
#include "SimpleKZRanks/database.sp"
#include "SimpleKZRanks/menus.sp"
#include "SimpleKZRanks/misc.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNatives();
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



/*===============================  Client and Map Events  ===============================*/

public void OnClientAuthorized(int client, const char[] auth) {
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
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_RECORD);
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_MAP);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_RECORD);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_MAP);
	SetupMap();
}



/*===============================  SimpleKZ Events  ===============================*/

public void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType) {
	gB_ConnectedToDB = true;
	gH_DB = database;
	g_DBType = DBType;
	DB_CreateTables();
}

public void SimpleKZ_OnTimerEnd(int client, int course, MovementStyle style, float time, int teleportsUsed, float theoreticalTime) {
	DB_ProcessTimerEnd(client, style, course, time, teleportsUsed, theoreticalTime);
}

public void SimpleKZ_OnNewRecord(int client, int mapID, int course, MovementStyle style, RecordType recordType, float runTime) {
	if (mapID != gI_CurrentMapID) {
		return;
	}
	
	// Print new record message to chat and play new record sound
	if (course == 0) {
		switch (recordType) {
			case RecordType_Map: {
				CPrintToChatAll(" %t", "New Record - Map", client, gC_StylePhrases[style]);
			}
			case RecordType_Pro: {
				CPrintToChatAll(" %t", "New Record - Pro", client, gC_StylePhrases[style]);
			}
			case RecordType_MapAndPro: {
				CPrintToChatAll(" %t", "New Record - Map and Pro", client, gC_StylePhrases[style]);
			}
		}
	}
	else {
		switch (recordType) {
			case RecordType_Map: {
				CPrintToChatAll(" %t", "New Bonus Record - Map", client, course, gC_StylePhrases[style]);
			}
			case RecordType_Pro: {
				CPrintToChatAll(" %t", "New Bonus Record - Pro", client, course, gC_StylePhrases[style]);
			}
			case RecordType_MapAndPro: {
				CPrintToChatAll(" %t", "New Bonus Record - Map and Pro", client, course, gC_StylePhrases[style]);
			}
		}
	}
	
	EmitSoundToAll(REL_SOUNDPATH_BEAT_RECORD);
}

public void SimpleKZ_OnNewPersonalBest(int client, int mapID, int course, MovementStyle style, TimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank) {
	if (mapID != gI_CurrentMapID) {
		return;
	}
	
	// Print new PB message to chat and play sound if first time beating the map PRO
	if (course == 0) {
		switch (timeType) {
			case TimeType_Normal: {
				// Only printing MAP time improvement to the achieving player due to spam complaints
				if (firstTime) {
					CPrintToChat(client, " %t", "New PB - First Time", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else {
					CPrintToChat(client, " %t", "New PB - Improve", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case TimeType_Pro: {
				if (firstTime) {
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
					UpdateCompletionMVPStars(client);
					EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
					EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
				}
				else {
					CPrintToChatAll(" %t", "New PB - Improve (Pro)", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
		}
	}
	else {
		switch (timeType) {
			case TimeType_Normal: {
				// Only printing MAP time improvement to the achieving player due to spam complaints
				if (firstTime) {
					CPrintToChat(client, " %t", "New PB - First Time", client, rank, maxRank, gC_StylePhrases[style]);
				}
				else {
					CPrintToChat(client, " %t", "New PB - Improve", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
			case TimeType_Pro: {
				if (firstTime) {
					CPrintToChatAll(" %t", "New PB - First Time (Pro)", client, rank, maxRank, gC_StylePhrases[style]);
					EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
					EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
				}
				else {
					CPrintToChatAll(" %t", "New PB - Improve (Pro)", client, SimpleKZ_FormatTime(improvement), rank, maxRank, gC_StylePhrases[style]);
				}
			}
		}
	}
} 