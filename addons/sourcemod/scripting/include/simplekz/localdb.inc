/* 	
	SimpleKZ Local DB Include File
	
	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_localdb_included_
#endinput
#endif
#define _simplekz_localdb_included_

#include <simplekz/core>



/*===============================  Enumerations  ===============================*/

enum DatabaseType
{
	DatabaseType_None = -1, 
	DatabaseType_MySQL, 
	DatabaseType_SQLite
}



/*===============================  Stocks  ===============================*/

/**
 * Converts a time float (seconds) to an integer (milliseconds).
 *
 * @param time			Time in seconds.
 * @return				Time in milliseconds.
 */
stock int SKZ_DB_TimeFloatToInt(float time)
{
	return RoundFloat(time * 1000.0);
}

/**
 * Converts a time integer (milliseconds) to a float (seconds).
 *
 * @param time			Time in milliseconds.
 * @return				Time in seconds.
 */
stock float SKZ_DB_TimeIntToFloat(int time)
{
	return time / 1000.0;
}



/*===============================  Forwards  ===============================*/

/**
 * Called when simplekz-localdb has connected to the database.
 *
 * @param database		Database handle.
 * @param DBType		Database type.
 * @noreturn
 */
forward void SKZ_DB_OnDatabaseConnect(Database database, DatabaseType DBType);

/**
 * Called when a player is ready for database interaction.
 * At this point, the player is present and updated in the "Players" table.
 *
 * @param client		Client index.
 * @param steamID		SteamID32 of the player.
 * @noreturn
 */
forward void SKZ_DB_OnClientSetup(int client, int steamID);

/**
 * Called when the current map is ready for database interaction.
 * At this point, the map is present and updated in the "Maps" table.
 *
 * @param mapID			MapID from the "Maps" table.
 * @noreturn
 */
forward void SKZ_DB_OnMapSetup(int mapID);

/**
 * Called when a time has been inserted into the database.
 *
 * @param client			Client index.
 * @param steamID			SteamID32 of the player.
 * @param mapID				MapID from the "Maps" table.
 * @param course    		Course number e.g. 0=main, 1='bonus1' etc.
 * @param style				Player's movement style.
 * @param runTimeMS			Player's end time in milliseconds.
 * @param teleportsUsed		Number of teleports used by player.
 * @param theoRunTimeMS		Theoretical end time without using teleports in milliseconds.
 * @noreturn
 */
forward void SKZ_DB_OnTimeInserted(int client, int steamID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoRunTimeMS);



/*===============================  Natives  ===============================*/

/**
 * Gets the SimpleKZ local database handle.
 *
 * @param database		Database handle (null if connection hasn't been made).
 * @noreturn
 */
native void SKZ_DB_GetDatabase(Database &database);

/**
 * Gets the SimpleKZ local database type.
 *
 * @return				Database type.
 */
native DatabaseType SKZ_DB_GetDatabaseType();

/**
 * Gets the current map's MapID as in the "Maps" table.
 *
 * @return				MapID from the "Maps" table.
 */
native int SKZ_DB_GetCurrentMapID();



/*===============================  Dependency  ===============================*/

public SharedPlugin __pl_simplekz_localdb = 
{
	name = "simplekz-localdb", 
	file = "simplekz-localdb.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_simplekz_localdb_SetNTVOptional()
{
	MarkNativeAsOptional("SKZ_DB_GetDatabase");
	MarkNativeAsOptional("SKZ_DB_GetDatabaseType");
	MarkNativeAsOptional("SKZ_DB_GetCurrentMapID");
}
#endif