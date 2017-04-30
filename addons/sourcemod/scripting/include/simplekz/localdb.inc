/* 	
	Simple KZ Local DB Include File
	
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
 * @param time				Time in seconds.
 * @return					Number of milliseconds.
 */
stock int SKZ_DB_TimeFloatToInt(float time)
{
	return RoundFloat(time * 1000.0);
}

/**
 * Converts a time integer (milliseconds) to a float (seconds).
 *
 * @param time				Time in milliseconds.
 * @return					Number of seconds.
 */
stock float SKZ_DB_TimeIntToFloat(int time)
{
	return time / 1000.0;
}



/*===============================  Forwards  ===============================*/

/**
 * Called when simplekz-localdb has connected to the database.
 *
 * @param database			Database handle.
 * @param DBType			Database type (see DatabaseType enumeration).
 * @noreturn
 */
forward void SKZ_DB_OnDatabaseConnect(Database database, DatabaseType DBType);

/**
 * Called when simplekz-localdb has inserted/updated a player in the "Players" database table.
 *
 * @param client				Client entity index (-1 if client is no longer present).
 * @param steamID				SteamID32 of the player.
 * @noreturn
 */
forward void SKZ_DB_OnPlayerSetup(int client, int steamID);

/**
 * Called when simplekz-localdb has retrieved the current map's MapID from the "Maps" database table.
 *
 * @param mapID				MapID from the "Maps" database table.
 * @noreturn
 */
forward void SKZ_DB_OnMapIDRetrieved(int mapID);

/**
 * Called when simplekz-localdb successfully saves a time to the database.
 *
 * @param client				Client entity index (-1 if client is no longer present).
 * @param steamID				SteamID32 of the player.
 * @param mapID					MapID from the "Maps" database table.
 * @param course				Which part of the map (main=0, bonus1=1, bonus2=2 etc.).
 * @param style					The movement style of the player.
 * @param runTimeMS				Player's end time (milliseconds).
 * @param teleportsUsed			Number of teleports the player used.
 * @param theoreticalRunTimeMS	Theoretical end time without using teleports (milliseconds).
 * @noreturn
 */
forward void SKZ_DB_OnTimeInserted(int client, int steamID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS);



/*===============================  Natives  ===============================*/

/**
 * Gets the simplekz-localdb database handle.
 *
 * @param database			Database handle.
 * @noreturn
 */
native void SKZ_DB_GetDatabase(Database &database);

/**
 * Gets the simplekz-localdb database type.
 *
 * @return					Database type (see DatabaseType enumeration).
 */
native DatabaseType SKZ_DB_GetDatabaseType();

/**
 * Gets the current map's MapID as retrieved from the "Maps" database table.
 *
 * @return					MapID from the "Maps" database table.
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