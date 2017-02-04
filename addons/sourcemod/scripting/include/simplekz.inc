/* 	Simple KZ API Include File
	Author: DanZay
	
	Plugin Version: 0.6.0
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

/*===============================  Double Include Prevention  ===============================*/
#if defined _simplekz_included_
#endinput
#endif
#define _simplekz_included_



/*===============================  Forwards  ===============================*/

/**
 * Called when the player starts their timer.
 *
 * @param client			Client entity index.
 * @param map				The name of the map (without prefixes e.g. workshop/).
 * @param firstStart		True if it is the player's first time starting since last map change.
 * @noreturn
 */
forward void SimpleKZ_OnTimerStarted(int client, const char[] map, bool firstStart);

/**
 * Called when the player ends their timer.
 *
 * @param client			Client entity index.
 * @param map				The name of the map (without prefixes e.g. workshop/).
 * @param time				Player's end time.
 * @param teleportsUsed		Number of teleports the player used.
 * @param theoreticalTime	Theoretical end time without using teleports.
 * @noreturn
 */
forward void SimpleKZ_OnTimerEnded(int client, const char[] map, float time, int teleportsUsed, float theoreticalTime);

/**
 * Called when the server connects to a SimpleKZ database.
 *
 * @param database			Database handle.
 * @param map				Database type (0 = MySQL, 1 = SQLite)
 * @noreturn
 */
forward void SimpleKZ_OnDatabaseConnect(Database database, int DBType);



/*===============================  Natives  ===============================*/

/**
 * Starts the players timer.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_StartTimer(int client);

/**
 * Ends the players timer.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_EndTimer(int client);

/**
 * Forces the players timer to stop without calling SimpleKZ_OnTimerEnded. Intended for run invalidation.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_ForceStopTimer(int client); 