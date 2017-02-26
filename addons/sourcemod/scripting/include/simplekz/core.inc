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
 * Called when the player changes their movement style.
 *
 * @param client			Client entity index.
 * @param newStyle			Movement style they changed to.
 * @noreturn
 */
forward void SimpleKZ_OnChangeMovementStyle(int client, MovementStyle newStyle);

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
 * @param course			Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style				The movement style of the player.
 * @noreturn
 */
forward void SimpleKZ_OnTimerStart(int client, int course, MovementStyle style);

/**
 * Called when the player ends their timer.
 *
 * @param client			Client entity index.
 * @param course			Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style				The movement style of the player.
 * @param time				Player's end time.
 * @param teleportsUsed		Number of teleports the player used.
 * @param theoreticalTime	Theoretical end time without using teleports.
 * @noreturn
 */
forward void SimpleKZ_OnTimerEnd(int client, int course, MovementStyle style, float time, int teleportsUsed, float theoreticalTime);

/**
 * Called when the player's timer has been force stopped (without finishing the map).
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerForceStop(int client);

/**
 * Called when the player pauses.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnPlayerPause(int client);

/**
 * Called when the player resumes.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnPlayerResume(int client);

/**
 * Called when the player is teleported due to a SimpleKZ timer command.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnPlayerTeleport(int client);

/**
 * Called when the server connects to a SimpleKZ database.
 *
 * @param database			Database handle.
 * @param DBType			Database type (see DatabaseType enumeration)
 * @noreturn
 */
forward void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType);

/**
 * Called after SimpleKZ Core retrieves a client's PlayerID from SimpleKZ Core's "Players" database table.
 *
 * @param client			The name of the map (without prefixes e.g. workshop/).
 * @param playerID			PlayerID from SimpleKZ Core's "Players" database table.
 * @noreturn
 */
forward void SimpleKZ_OnRetrievePlayerID(int client, int playerID);



/*===============================  Natives  ===============================*/

/**
 * Gets the whether or not the player's latest jump was a plugin-based perfect b-hop.
 *
 * @param client			Client entity index.
 * @return					whether or not the player's latest jump was a perfect b-hop.
 */
native bool SimpleKZ_GetHitPerf(int client);

/**
 * Forces the player's timer to stop. Intended for run invalidation.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_ForceStopTimer(int client);

/**
 * Forces all players' timers to stop. Intended for run invalidation.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_ForceStopTimerAll(int client);

/**
 * Gets whether or not the player's timer is running i.e. isn't 'stopped' (regardless of paused state).
 *
 * @param client    		Client entity index.
 * @return					Whether or not the player's timer is running.
 */
native bool SimpleKZ_GetTimerRunning(int client);

/**
 * Gets what course the player is currently running.
 *
 * @param client    		Client entity index.
 * @return					Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 */
native bool SimpleKZ_GetCurrentCourse(int client);

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

/**
 * Gets the default movement style as set by convar kz_default_style.
 *
 * @return					The default movement style (see MovementStyle enumeration).
 */
native MovementStyle SimpleKZ_GetDefaultStyle();

/**
 * Gets the player's chosen movement style.
 *
 * @param client			Client entity index.
 * @return					The player's movement style.
 */
native MovementStyle SimpleKZ_GetOptionStyle(int client);

/**
 * Sets the player's movement style.
 *
 * @param client			Client entity index.
 * @param style				What to set the player's movement style to.
 * @noreturn
 */
native void SimpleKZ_SetOptionStyle(int client, MovementStyle style);

/**
 * Gets the client's PlayerID as retrieved from SimpleKZ Core's "Players" database table. This is accurate after SimpleKZ_OnRetrievePlayerID is called after the client is authorised.
 *
 * @param client			Client entity index.
 * @return					PlayerID from SimpleKZ Core's "Players" database table.
 */
native int SimpleKZ_GetPlayerID(int client);



/*===============================  Stocks  ===============================*/

stock char[] SimpleKZ_FormatTime(float time) {
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