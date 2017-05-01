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
	version = "0.12.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



Handle gH_OnDatabaseConnect;
Handle gH_OnClientSetup;
Handle gH_OnMapIDRetrieved;
Handle gH_OnTimeInserted;

KZPlayer g_KZPlayer[MAXPLAYERS + 1];
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



/*===============================  Plugin Forwards  ===============================*/

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
	
	CreateKZPlayers();
	CreateGlobalForwards();
	CreateRegexes();
	
	DB_SetupDatabase();
}

public void OnAllPluginsLoaded()
{
	if (gB_LateLoad)
	{
		OnLateLoad();
	}
}

void OnLateLoad()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientAuthorized(client))
		{
			DB_SetupClient(g_KZPlayer[client]);
		}
	}
}



/*===============================  Other Forwards  ===============================*/

public void OnClientAuthorized(int client, const char[] auth)
{
	DB_SetupClient(g_KZPlayer[client]);
}

public void SKZ_OnClientSetup(int client)
{
	DB_LoadOptions(g_KZPlayer[client]);
}

public void OnClientDisconnect(int client)
{
	if (!IsFakeClient(client))
	{
		DB_SaveOptions(g_KZPlayer[client]);
	}
}

public void OnMapStart()
{
	DB_SetupMap();
}

public void SKZ_OnTimerEnd(int client, int course, KZStyle style, float time, int teleportsUsed, float theoreticalTime)
{
	DB_SaveTime(g_KZPlayer[client], course, style, time, teleportsUsed, theoreticalTime);
}

public void SKZ_DB_OnMapIDRetrieved(int mapID)
{
	DB_SetupMapCourses();
}



/*===============================  Functions  ===============================*/

void CreateKZPlayers()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		g_KZPlayer[client] = new KZPlayer(client);
	}
}

void CreateRegexes()
{
	gRE_BonusStartButton = CompileRegex("^climb_bonus(\\d+)_startbutton$");
} 