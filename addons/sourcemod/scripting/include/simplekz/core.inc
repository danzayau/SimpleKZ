/* 	Simple KZ Core Include File
	Author: DanZay
	
	Plugin Version: 0.9.0
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_core_included_
#endinput
#endif
#define _simplekz_core_included_



/*===============================  Definitions  ===============================*/

#define SIMPLEKZ_NUMBER_OF_STYLES 2



/*===============================  Enumerations  ===============================*/

enum RunType {
	RunType_Normal = 0, 
	RunType_Pro, 
	RunType_Theoretical // For convenience
}

enum MovementStyle {
	MovementStyle_Standard = 0, 
	MovementStyle_Legacy
}

enum DatabaseType {
	DatabaseType_None = -1, 
	DatabaseType_MySQL, 
	DatabaseType_SQLite
}



/*===============================  Forwards  ===============================*/

/**
 * Called when the server connects to a SimpleKZ database.
 *
 * @param database			Database handle.
 * @param map				Database type (see DatabaseType enumeration)
 * @noreturn
 */
forward void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType);

/**
 * Called when the player changes their movement style.
 *
 * @param client			Client entity index.
 * @param style				Movement style they changed to.
 * @noreturn
 */
forward void SimpleKZ_OnChangeMovementStyle(int client, MovementStyle style);

/**
 * Called when the player hits a plugin-based perfect b-hop.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnPlayerPerfectBunnyhop(int client);

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
forward void SimpleKZ_OnTimerEnded(int client, float time, int teleportsUsed, float theoreticalTime, MovementStyle style);

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
 * Called when the player is teleported due to a SimpleKZ timer command.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerTeleport(int client);



/*===============================  Natives  ===============================*/

/**
 * Gets the player's chosen movement style.
 *
 * @param client			Client entity index.
 * @return					The player's movement style.
 */
native MovementStyle SimpleKZ_GetMovementStyle(int client);

/**
 * Sets the player's movement style.
 *
 * @param client			Client entity index.
 * @param style				What to set the player's movement style to.
 * @noreturn
 */
native void SimpleKZ_SetMovementStyle(int client, MovementStyle style);

/**
 * Gets the whether or not the player's latest jump was a plugin-based perfect b-hop.
 *
 * @param client			Client entity index.
 * @return					whether or not the player's latest jump was a perfect b-hop.
 */
native bool SimpleKZ_GetHitPerf(int client);

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
 * Gets whether or not the player's timer is running i.e. isn't 'stopped' (regardless of paused state).
 *
 * @param client    		Client entity index.
 * @return					Whether or not the player's timer is running.
 */
native bool SimpleKZ_GetTimerRunning(int client);

/**
 * Gets whether or not the player is paused.
 *
 * @param client    		Client entity index.
 * @return					Whether or not the player is paused.
 */
native bool SimpleKZ_GetPaused(int client);

/**
 * Gets the player's current run time. Runtime is reset when the player's timer is started.
 *
 * @param client    		Client entity index.
 * @return					The player's current run time.
 */
native float SimpleKZ_GetCurrentTime(int client);

/**
 * Gets the player's current checkpoint count. Checkpoint count is reset when the player's timer is started.
 *
 * @param client    		Client entity index.
 * @return					The player's current checkpoint count.
 */
native int SimpleKZ_GetCheckpointCount(int client);

/**
 * Teleports the player to their start position or else respawns them.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_TeleportToStart(int client);

/**
 * Tries to set a new checkpoint at the player's current position.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_MakeCheckpoint(int client);

/**
 * Teleports the player to their latest checkpoint.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_TeleportToCheckpoint(int client);

/**
 * Undoes the player's last teleport by teleporting them back.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_UndoTeleport(int client);

/**
 * Tries to pause the player's timer (pausing freezes the player if they aren't on a time).
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_Pause(int client);

/**
 * Resumes the player's timer.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_Resume(int client);

/**
 * Toggles the paused state of the player.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_TogglePause(int client);



/*===============================  Stocks  ===============================*/

stock char[] FormatTimeFloat(float time) {
	char formattedTime[12];
	
	int roundedTime = RoundFloat(time * 100); // Time rounded to number of centiseconds
	
	int centiseconds = roundedTime % 100;
	roundedTime = (roundedTime - centiseconds) / 100;
	int seconds = roundedTime % 60;
	roundedTime = (roundedTime - seconds) / 60;
	int minutes = roundedTime % 60;
	roundedTime = (roundedTime - minutes) / 60;
	int hours = roundedTime;
	
	if (hours == 0) {
		FormatEx(formattedTime, sizeof(formattedTime), "%02d:%02d.%02d", minutes, seconds, centiseconds);
	}
	else {
		FormatEx(formattedTime, sizeof(formattedTime), "%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds);
	}
	return formattedTime;
} 