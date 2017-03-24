/* 	Simple KZ Core Include File
	Author: DanZay
	
	Plugin Version: 0.10.0
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_core_included_
#endinput
#endif
#define _simplekz_core_included_


/*===============================  Enumerations  ===============================*/

enum KZTimeType {
	KZTimeType_Normal = 0, 
	KZTimeType_Pro, 
	KZTimeType_Theoretical
}

enum KZOption {
	KZOption_Style = 0, 
	KZOption_ShowingTeleportMenu, 
	KZOption_ShowingInfoPanel, 
	KZOption_ShowingKeys, 
	KZOption_ShowingPlayers, 
	KZOption_ShowingWeapon, 
	KZOption_AutoRestart, 
	KZOption_SlayOnEnd, 
	KZOption_Pistol, 
	KZOption_CheckpointMessages, 
	KZOption_CheckpointSounds, 
	KZOption_TeleportSounds, 
	KZOption_TimerText
}

/*	Each option has it's own enumeration to specify the meaning of its value. */

enum KZStyle {
	KZStyle_Standard = 0, 
	KZStyle_Legacy
}

enum KZShowingTeleportMenu {
	KZShowingTeleportMenu_Disabled = 0, 
	KZShowingTeleportMenu_Enabled
}

enum KZShowingInfoPanel {
	KZShowingInfoPanel_Disabled = 0, 
	KZShowingInfoPanel_Enabled
}

enum KZShowingKeys {
	KZShowingKeys_Disabled = 0, 
	KZShowingKeys_Enabled
}

enum KZShowingPlayers {
	KZShowingPlayers_Disabled = 0, 
	KZShowingPlayers_Enabled
}

enum KZShowingWeapon {
	KZShowingWeapon_Disabled = 0, 
	KZShowingWeapon_Enabled
}

enum KZAutoRestart {
	KZAutoRestart_Disabled = 0, 
	KZAutoRestart_Enabled
}

enum KZSlayOnEnd {
	KZSlayOnEnd_Disabled = 0, 
	KZSlayOnEnd_Enabled
}

enum KZPistol {
	KZPistol_USP = 0, 
	KZPistol_Glock, 
	KZPistol_P250, 
	KZPistol_Dualies, 
	KZPistol_Deagle, 
	KZPistol_CZ75A, 
	KZPistol_FiveSeveN, 
	KZPistol_Tec9
}

enum KZCheckpointMessages {
	KZCheckpointMessages_Disabled = 0, 
	KZCheckpointMessages_Enabled
}

enum KZCheckpointSounds {
	KZCheckpointSounds_Disabled = 0, 
	KZCheckpointSounds_Enabled
}

enum KZTeleportSounds {
	KZTeleportSounds_Disabled = 0, 
	KZTeleportSounds_Enabled
}

enum KZTimerText {
	KZTimerText_Disabled = 0, 
	KZTimerText_Top, 
	KZTimerText_Bottom
}



/*===============================  Forwards  ===============================*/

/**
 * Called when the SimpleKZ Core has set up the client after authorization.
 * At this point, many variables relating to the client (e.g. options) have been set.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnClientSetup(int client);

/**
 * Called when the player changes an option.
 *
 * @param client			Client entity index.
 * @param option			The option that was changed
 * @param newValue			The new value of the option.
 * @noreturn
 */
forward void SimpleKZ_OnChangeOption(int client, KZOption option, any newValue);

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
forward void SimpleKZ_OnTimerStart(int client, int course, KZStyle style);

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
forward void SimpleKZ_OnTimerEnd(int client, int course, KZStyle style, float time, int teleportsUsed, float theoreticalTime);

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



/*===============================  Natives  ===============================*/

/**
 * Gets the whether or not the player's latest jump was a plugin-based perfect b-hop.
 *
 * @param client			Client entity index.
 * @return					whether or not the player's latest jump was a perfect b-hop.
 */
native bool SimpleKZ_GetHitPerf(int client);

/**
 * Starts the player's timer for a course on the current map.
 *
 * @param client    		Client entity index.
 * @param course    		Course number (0 = main, 1+ = bonus).
 * @noreturn
 */
native void SimpleKZ_StartTimer(int client, int course);

/**
 * Ends the player's timer for a course on the current map.
 * Only works if the player's timer is started for that course.
 *
 * @param client    		Client entity index.
 * @param course    		Course number (0 = main, 1+ = bonus).
 * @noreturn
 */
native void SimpleKZ_EndTimer(int client, int course);

/**
 * Forces the player's timer to stop.
 * Intended for run invalidation.
 *
 * @param client    		Client entity index.
 * @return					Whether or not the player's timer was stopped.
 */
native bool SimpleKZ_ForceStopTimer(int client);

/**
 * Forces all players' timers to stop.
 * Intended for run invalidation.
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
 * Gets the player's current run time.
 * Runtime is reset when the player's timer is started.
 *
 * @param client    		Client entity index.
 * @return					The player's current run time.
 */
native float SimpleKZ_GetCurrentTime(int client);

/**
 * Gets the player's current checkpoint count.
 * Checkpoint count is reset when the player's timer is started.
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
 * @return					The default movement style (see KZStyle enumeration).
 */
native KZStyle SimpleKZ_GetDefaultStyle();

/**
 * Gets the current value of a player's option. Note that this
 * returns an int, whereas options use an enumerated tag.
 * Use the KZPlayer method map to simplify this caveat.
 *
 * @param client			Client entity index.
 * @param option			The SimpleKZ option (see KZOption enumeration).
 * @return					The current value of a player's option.
 */
native int SimpleKZ_GetOption(int client, KZOption option);

/**
 * Sets the player's option value.
 *
 * @param client			Client entity index.
 * @param option			The SimpleKZ option (see KZOption enumeration).
 * @param optionValue		What to set the player's option to.
 * @noreturn
 */
native void SimpleKZ_SetOption(int client, KZOption option, any optionValue); 