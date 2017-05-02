#include <sourcemod>

#include <cstrike>
#include <sdktools>

#include <colorvariables>
#include <simplekz>

#include <simplekz/localdb>
#include <simplekz/localranks>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "SimpleKZ Local Ranks", 
	author = "DanZay", 
	description = "SimpleKZ Local Ranks Module", 
	version = "0.12.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



Handle gH_SKZ_OnNewRecord;
Handle gH_SKZ_OnNewPersonalBest;

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
	"Style - Legacy", 
	"Style - Competitive"
};

// Time type translation phrases for chat messages (respective to KZTimeType enum)
char gC_TimeTypePhrases[view_as<int>(KZTimeType)][] = 
{
	"Time Type - Nub", 
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
	
	TryGetDatabaseInfo();
}



/*===============================  SimpleKZ Forwards  ===============================*/

public void SKZ_DB_OnDatabaseConnect(Database database, DatabaseType DBType)
{
	gH_DB = database;
	g_DBType = DBType;
	DB_CreateTables();
	CompletionMVPStarsUpdateAll();
}

public void SKZ_DB_OnTimeInserted(int client, int steamID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS)
{
	if (IsValidClient(client))
	{
		DB_ProcessNewTime(client, steamID, mapID, course, style, runTimeMS, teleportsUsed);
	}
}

public void SKZ_DB_OnNewRecord(int client, int steamID, int mapID, int course, KZStyle style, KZRecordType recordType, float runTime)
{
	if (IsValidClient(client) && mapID == SKZ_DB_GetCurrentMapID())
	{
		AnnounceNewRecord(client, course, style, recordType);
	}
}

public void SKZ_DB_OnNewPersonalBest(int client, int steamID, int mapID, int course, KZStyle style, KZTimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank)
{
	if (IsValidClient(client) && mapID == SKZ_DB_GetCurrentMapID() && rank != 1)
	{
		AnnounceNewPersonalBest(client, course, style, timeType, firstTime, improvement, rank, maxRank);
	}
}



/*===============================  Functions  ===============================*/

void CreateMenus()
{
	MapTopMenuCreateMenus();
	PlayerTopMenuCreateMenus();
}

void TryGetDatabaseInfo()
{
	SKZ_DB_GetDatabase(gH_DB);
	if (gH_DB != null)
	{
		g_DBType = SKZ_DB_GetDatabaseType();
		DB_CreateTables();
		CompletionMVPStarsUpdateAll();
	}
} 