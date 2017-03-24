/* 	Simple KZ Local DB Include File
	Author: DanZay
	
	Plugin Version: 0.10.1
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_localdb_included_
#endinput
#endif
#define _simplekz_localdb_included_


/*===============================  Enumerations  ===============================*/

enum DatabaseType {
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
stock int SimpleKZ_TimeFloatToInt(float time) {
	return RoundFloat(time * 1000.0);
}

/**
 * Converts a time integer (milliseconds) to a float (seconds).
 *
 * @param time				Time in milliseconds.
 * @return					Number of seconds.
 */
stock float SimpleKZ_TimeIntToFloat(int time) {
	return time / 1000.0;
}



/*===============================  Forwards  ===============================*/

/**
 * Called when the server connects to a SimpleKZ database.
 *
 * @param database			Database handle.
 * @param DBType			Database type (see DatabaseType enumeration)
 * @noreturn
 */
forward void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType);

/**
 * Called when simplekz-localdb retrieves a client's PlayerID from SimpleKZ Core's "Players" database table.
 *
 * @param client			The name of the map (without prefixes e.g. workshop/).
 * @param playerID			PlayerID from SimpleKZ Core's "Players" database table.
 * @noreturn
 */
forward void SimpleKZ_OnRetrievePlayerID(int client, int playerID);

/**
 * Called when simplekz-localdb retrieves the current map's MapID from the "Maps" database table.
 *
 * @param mapID				MapID from SimpleKZ Core's "Maps" database table.
 * @noreturn
 */
forward void SimpleKZ_OnRetrieveCurrentMapID(int mapID);

/**
 * Called when simplekz-localdb successfully saves a player's time to the database.
 *
 * @param client				Client entity index.
 * @param playerID				PlayerID from SimpleKZ Core's "Players" database table.
 * @param mapID					MapID from SimpleKZ Core's "Maps" database table.
 * @param course				Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style					The movement style of the player.
 * @param runTimeMS				Player's end time (milliseconds).
 * @param teleportsUsed			Number of teleports the player used.
 * @param theoreticalRunTimeMS	Theoretical end time without using teleports (milliseconds).
 * @noreturn
 */
forward void SimpleKZ_OnSaveTimeToDB(int playerID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS);



/*===============================  Natives  ===============================*/

/**
 * Gets the client's PlayerID as retrieved from SimpleKZ Core's "Players" database table.
 * This is accurate after SimpleKZ_OnRetrievePlayerID is called after the client is authorised.
 *
 * @param client			Client entity index.
 * @return					PlayerID from SimpleKZ Core's "Players" database table.
 */
native int SimpleKZ_GetPlayerID(int client);

/**
 * Gets the current map's MapID as retrieved from SimpleKZ Core's "Maps" database table.
 * This is accurate after SimpleKZ_OnRetrieveCurrentMapID is called after the map is started.
 *
 * @return					MapID from SimpleKZ Ranks' "Maps" database table.
 */
native int SimpleKZ_GetCurrentMapID(); 