#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colorvariables>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "Simple KZ Local Ranks", 
	author = "DanZay", 
	description = "Local ranks module for SimpleKZ.", 
	version = "0.11.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



Handle gH_SKZ_OnNewRecord;
Handle gH_SKZ_OnNewPersonalBest;

bool gB_LateLoad;

Database gH_DB = null;
DatabaseType g_DBType = DatabaseType_None;

Menu gH_MapTopMenu[MAXPLAYERS + 1];
Menu gH_MapTopSubMenu[MAXPLAYERS + 1];
char gC_MapTopMapName[MAXPLAYERS + 1][64];
int gI_MapTopMapID[MAXPLAYERS + 1];
int gI_MapTopCourse[MAXPLAYERS + 1];
KZStyle g_MapTopStyle[MAXPLAYERS + 1];

Menu gH_PlayerTopMenu[MAXPLAYERS + 1];
Menu gH_PlayerTopSubMenu[MAXPLAYERS + 1];
KZStyle g_PlayerTopStyle[MAXPLAYERS + 1];

// Styles translation phrases for chat messages (respective to KZStyle enum)
char gC_StylePhrases[view_as<int>(KZStyle)][] = 
{
	"Style - Standard", 
	"Style - Legacy"
};

// Time type translation phrases for chat messages (respective to KZTimeType enum)
char gC_TimeTypePhrases[view_as<int>(KZTimeType)][] = 
{
	"Time Type - Normal", 
	"Time Type - Pro", 
	"Time Type - Theoretical"
};



#include "simplekz-localranks/database/sql.sp"

#include "simplekz-localranks/api.sp"
#include "simplekz-localranks/commands.sp"
#include "simplekz-localranks/database.sp"
#include "simplekz-localranks/misc.sp"

#include "simplekz-localranks/database/create_tables.sp"
#include "simplekz-localranks/database/get_completion.sp"
#include "simplekz-localranks/database/open_maptop.sp"
#include "simplekz-localranks/database/open_maptop20.sp"
#include "simplekz-localranks/database/open_playertop20.sp"
#include "simplekz-localranks/database/print_pbs.sp"
#include "simplekz-localranks/database/print_records.sp"
#include "simplekz-localranks/database/process_new_time.sp"
#include "simplekz-localranks/database/update_ranked_map_pool.sp"

#include "simplekz-localranks/menus/maptop.sp"
#include "simplekz-localranks/menus/playertop.sp"



/*===============================  Plugin Forwards  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("simplekz-localranks");
	gB_LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("This plugin is only for CS:GO.");
	}
	
	LoadTranslations("simplekz-core.phrases");
	LoadTranslations("simplekz-localranks.phrases");
	
	CreateMenus();
	CreateGlobalForwards();
	CreateCommands();
	
	if (gB_LateLoad)
	{
		OnLateLoad();
	}
}

public void OnLateLoad()
{
	SKZ_GetDB(gH_DB);
	g_DBType = SKZ_GetDBType();
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("simplekz-core"))
	{
		SetFailState("This plugin requires the SimpleKZ Core plugin.");
	}
	else if (!LibraryExists("simplekz-localdb"))
	{
		SetFailState("This plugin requires the SimpleKZ Local DB plugin.");
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual("simplekz-core", name))
	{
		SetFailState("This plugin requires the SimpleKZ Core plugin.");
	}
	else if (StrEqual("simplekz-localdb", name))
	{
		SetFailState("This plugin requires the SimpleKZ Local DB plugin.");
	}
}



/*===============================  SimpleKZ Forwards  ===============================*/

public void SKZ_OnDatabaseConnect(Database database, DatabaseType DBType)
{
	gH_DB = database;
	g_DBType = DBType;
	DB_CreateTables();
	UpdateCompetionMVPStarsAll();
}

public void SKZ_OnStoreTimeInDB(int client, int playerID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS)
{
	DB_ProcessNewTime(client, playerID, mapID, course, style, runTimeMS, teleportsUsed);
}

public void SKZ_OnNewRecord(int client, int mapID, int course, KZStyle style, KZRecordType recordType, float runTime)
{
	if (mapID == SKZ_GetCurrentMapID())
	{
		AnnounceNewRecord(client, course, style, recordType);
	}
}

public void SKZ_OnNewPersonalBest(int client, int mapID, int course, KZStyle style, KZTimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank)
{
	if (mapID == SKZ_GetCurrentMapID() && rank != 1)
	{
		AnnounceNewPersonalBest(client, course, style, timeType, firstTime, improvement, rank, maxRank);
	}
}



/*===============================  Other Forwards  ===============================*/

public void OnMapStart()
{
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_RECORD);
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_MAP);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_RECORD);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_MAP);
}



/*===============================  Functions  ===============================*/

void CreateMenus()
{
	CreateMapTopMenuAll();
	CreatePlayerTopMenuAll();
} 