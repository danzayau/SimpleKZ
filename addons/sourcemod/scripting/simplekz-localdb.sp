#include <sourcemod>
#include <sdktools>
#include <geoip>
#include <regex>

#include <simplekz>

#include <simplekz/core>
#include <simplekz/localdb>

#pragma newdecls required
#pragma semicolon 1



public Plugin myinfo = 
{
	name = "SimpleKZ Local DB", 
	author = "DanZay", 
	description = "SimpleKZ Local Database Module", 
	version = "0.13.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};

Handle gH_OnDatabaseConnect;
Handle gH_OnClientSetup;
Handle gH_OnMapSetup;
Handle gH_OnTimeInserted;

bool gB_LateLoad;
Regex gRE_BonusStartButton;

Database gH_DB = null;
DatabaseType g_DBType = DatabaseType_None;
int gI_DBCurrentMapID;

#include "simplekz-localdb/api.sp"
#include "simplekz-localdb/database.sp"

#include "simplekz-localdb/database/sql.sp"
#include "simplekz-localdb/database/create_tables.sp"
#include "simplekz-localdb/database/load_options.sp"
#include "simplekz-localdb/database/save_options.sp"
#include "simplekz-localdb/database/save_time.sp"
#include "simplekz-localdb/database/setup_client.sp"
#include "simplekz-localdb/database/setup_database.sp"
#include "simplekz-localdb/database/setup_map.sp"
#include "simplekz-localdb/database/setup_map_courses.sp"



// =========================  PLUGIN  ========================= //

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	RegPluginLibrary("simplekz-localdb");
	gB_LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("This plugin is only for CS:GO.");
	}
	
	CreateGlobalForwards();
	CreateRegexes();
	
	DB_SetupDatabase();
	
	if (gB_LateLoad)
	{
		OnLateLoad();
	}
}

void OnLateLoad()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (SKZ_IsClientSetUp(client))
		{
			SKZ_OnClientSetup(client);
		}
	}
}



// =========================  OTHER  ========================= //

public void SKZ_OnClientSetup(int client)
{
	DB_SetupClient(client);
	DB_LoadOptions(client);
}

public void SKZ_DB_OnMapSetup(int mapID)
{
	DB_SetupMapCourses();
}

public void OnClientDisconnect(int client)
{
	if (!IsFakeClient(client))
	{
		DB_SaveOptions(client);
	}
}

public void OnMapStart()
{
	DB_SetupMap();
}

public void SKZ_OnTimerEnd_Post(int client, int course, int style, float time, int teleportsUsed, float theoreticalTime)
{
	DB_SaveTime(client, course, style, time, teleportsUsed, theoreticalTime);
}



// =========================  PRIVATE  ========================= //

static void CreateRegexes()
{
	gRE_BonusStartButton = CompileRegex("^climb_bonus(\\d+)_startbutton$");
} 