/* 	Simple KZ Core API
	Author: DanZay
*/

#if defined _simplekz_core_included_
#endinput
#endif
#define _simplekz_core_included_


/*===============================  Enumerations  ===============================*/

enum RunType {
	PRO = 0, 
	TP
}

enum DatabaseType {
	NONE = -1, 
	MYSQL, 
	SQLITE
}


/*===============================  Forwards  ===============================*/

/**
 * Called when the player starts their timer.
 *
 * @param client			Client entity index.
 * @param firstStart		True if it is the player's first time starting since last map change.
 * @noreturn
 */
forward void SimpleKZ_OnTimerStarted(int client, bool firstStart);

/**
 * Called when the player ends their timer.
 *
 * @param client			Client entity index.
 * @param time				Player's end time.
 * @param teleportsUsed		Number of teleports the player used.
 * @param theoreticalTime	Theoretical end time without using teleports.
 * @noreturn
 */
forward void SimpleKZ_OnTimerEnded(int client, float time, int teleportsUsed, float theoreticalTime);

/**
 * Called when the player pauses their timer.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerPaused(int client);

/**
 * Called when the player resumes their timer.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerResumed(int client);

/**
 * Called when the player's timer has been force stopped (without finishing the map).
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerForceStopped(int client);

/**
 * Called when the server connects to a SimpleKZ database.
 *
 * @param database			Database handle.
 * @param map				Database type (see DatabaseType enumeration)
 * @noreturn
 */
forward void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType);



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

/**
 * Gets the player's current run time.
 *
 * @param client    		Client entity index.
 * @return					The player's current run time. Returns -1.0 if not currently on a run.
 */
native float SimpleKZ_GetCurrentTime(int client); 