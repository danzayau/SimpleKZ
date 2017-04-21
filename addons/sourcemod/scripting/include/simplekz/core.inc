/* 	
	Simple KZ Core Include File
	
	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_core_included_
#endinput
#endif
#define _simplekz_core_included_



/*===============================  Enumerations  ===============================*/

enum KZTimeType
{
	KZTimeType_Normal = 0, 
	KZTimeType_Pro, 
	KZTimeType_Theoretical
}

enum KZStyleSetting
{
	KZStyleSetting_Accelerate = 0, 
	KZStyleSetting_Friction, 
	KZStyleSetting_AirAccelerate, 
	KZStyleSetting_LadderScaleSpeed, 
	KZStyleSetting_MaxVelocity, 
	KZStyleSetting_Gravity, 
	KZStyleSetting_EnableBunnyhopping, 
	KZStyleSetting_AutoBunnyhopping, 
	KZStyleSetting_StaminaMax, 
	KZStyleSetting_StaminaLandCost, 
	KZStyleSetting_StaminaJumpCost, 
	KZStyleSetting_StaminaRecoveryRate, 
	KZStyleSetting_MaxSpeed, 
	KZStyleSetting_WaterAccelerate, 
	KZStyleSetting_TimeBetweenDucks, 
	KZStyleSetting_AccelerateUseWeaponSpeed
}

enum KZOption
{
	KZOption_Style = 0, 
	KZOption_ShowingTPMenu, 
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
	KZOption_ErrorSounds, 
	KZOption_TimerText, 
	KZOption_SpeedText
}

/*	Each option has it's own enumeration to specify the meaning of its value,
	and so it's a bit easier to add more option values. */

enum KZStyle
{
	KZStyle_Standard = 0, 
	KZStyle_Legacy, 
	KZStyle_Competitive
}

enum KZShowingTPMenu
{
	KZShowingTPMenu_Disabled = 0, 
	KZShowingTPMenu_Enabled
}

enum KZShowingInfoPanel
{
	KZShowingInfoPanel_Disabled = 0, 
	KZShowingInfoPanel_Enabled
}

enum KZShowingKeys
{
	KZShowingKeys_Spectating = 0, 
	KZShowingKeys_Always, 
	KZShowingKeys_Disabled
}

enum KZShowingPlayers
{
	KZShowingPlayers_Disabled = 0, 
	KZShowingPlayers_Enabled
}

enum KZShowingWeapon
{
	KZShowingWeapon_Disabled = 0, 
	KZShowingWeapon_Enabled
}

enum KZAutoRestart
{
	KZAutoRestart_Disabled = 0, 
	KZAutoRestart_Enabled
}

enum KZSlayOnEnd
{
	KZSlayOnEnd_Disabled = 0, 
	KZSlayOnEnd_Enabled
}

enum KZPistol
{
	KZPistol_USP = 0, 
	KZPistol_Glock, 
	KZPistol_P250, 
	KZPistol_Dualies, 
	KZPistol_Deagle, 
	KZPistol_CZ75A, 
	KZPistol_FiveSeveN, 
	KZPistol_Tec9
}

enum KZCheckpointMessages
{
	KZCheckpointMessages_Disabled = 0, 
	KZCheckpointMessages_Enabled
}

enum KZCheckpointSounds
{
	KZCheckpointSounds_Disabled = 0, 
	KZCheckpointSounds_Enabled
}

enum KZTeleportSounds
{
	KZTeleportSounds_Disabled = 0, 
	KZTeleportSounds_Enabled
}

enum KZErrorSounds
{
	KZErrorSounds_Disabled = 0, 
	KZErrorSounds_Enabled
}

enum KZTimerText
{
	KZTimerText_Disabled = 0, 
	KZTimerText_InfoPanel, 
	KZTimerText_Bottom, 
	KZTimerText_Top
}

enum KZSpeedText
{
	KZSpeedText_Disabled = 0, 
	KZSpeedText_InfoPanel, 
	KZSpeedText_Bottom
}



/*===============================  Forwards  ===============================*/

/**
 * Called when the player starts their timer.
 *
 * @param client			Client entity index.
 * @param course			Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style				The movement style of the player.
 * @noreturn
 */
forward void SKZ_OnTimerStart(int client, int course, KZStyle style);

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
forward void SKZ_OnTimerEnd(int client, int course, KZStyle style, float time, int teleportsUsed, float theoreticalTime);

/**
 * Called when the player's timer has been force stopped (without finishing the map).
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnTimerForceStop(int client);

/**
 * Called when the player pauses.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnPause(int client);

/**
 * Called when the player resumes.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnResume(int client);

/**
 * Called when the player teleports to start.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnTeleportToStart(int client);

/**
 * Called when the player makes a checkpoint.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnCheckpoint(int client);

/**
 * Called when the player teleports to their checkpoint.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnTeleportToCheckpoint(int client);

/**
 * Called when the player undos teleport.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnUndoTeleport(int client);

/**
 * Called when the player changes an option.
 *
 * @param client			Client entity index.
 * @param option			The option that was changed
 * @param newValue			The new value of the option.
 * @noreturn
 */
forward void SKZ_OnChangeOption(int client, KZOption option, any newValue);

/**
 * Called when the player hits a plugin-based perfect b-hop.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SKZ_OnPerfectBunnyhop(int client);



/*===============================  Natives  ===============================*/

/**
 * Gets the whether or not the player's latest jump was a plugin-based perfect b-hop.
 *
 * @param client			Client entity index.
 * @return					whether or not the player's latest jump was a perfect b-hop.
 */
native bool SKZ_GetHitPerf(int client);

/**
 * Starts the player's timer for a course on the current map.
 *
 * @param client    		Client entity index.
 * @param course    		Course number (0 = main, 1+ = bonus).
 * @noreturn
 */
native void SKZ_StartTimer(int client, int course);

/**
 * Ends the player's timer for a course on the current map.
 * Only works if the player's timer is started for that course.
 *
 * @param client    		Client entity index.
 * @param course    		Course number (0 = main, 1+ = bonus).
 * @noreturn
 */
native void SKZ_EndTimer(int client, int course);

/**
 * Forces the player's timer to stop.
 * Intended for run invalidation.
 *
 * @param client    		Client entity index.
 * @return					Whether or not the player's timer was stopped.
 */
native bool SKZ_ForceStopTimer(int client);

/**
 * Forces all players' timers to stop.
 * Intended for run invalidation.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_ForceStopTimerAll(int client);

/**
 * Gets whether or not the player's timer is running i.e. isn't 'stopped' (regardless of paused state).
 *
 * @param client    		Client entity index.
 * @return					Whether or not the player's timer is running.
 */
native bool SKZ_GetTimerRunning(int client);

/**
 * Gets what course the player is currently running.
 *
 * @param client    		Client entity index.
 * @return					Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 */
native bool SKZ_GetCurrentCourse(int client);

/**
 * Gets whether or not the player is paused.
 *
 * @param client    		Client entity index.
 * @return					Whether or not the player is paused.
 */
native bool SKZ_GetPaused(int client);

/**
 * Gets the player's current run time.
 * Runtime is reset when the player's timer is started.
 *
 * @param client    		Client entity index.
 * @return					The player's current run time.
 */
native float SKZ_GetCurrentTime(int client);

/**
 * Gets the player's current checkpoint count.
 * Checkpoint count is reset when the player's timer is started.
 *
 * @param client    		Client entity index.
 * @return					The player's current checkpoint count.
 */
native int SKZ_GetCheckpointCount(int client);

/**
 * Teleports the player to their start position or else respawns them.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_TeleportToStart(int client);

/**
 * Tries to set a new checkpoint at the player's current position.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_MakeCheckpoint(int client);

/**
 * Teleports the player to their latest checkpoint.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_TeleportToCheckpoint(int client);

/**
 * Undoes the player's last teleport by teleporting them back.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_UndoTeleport(int client);

/**
 * Tries to pause the player's timer (pausing freezes the player if they aren't on a time).
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_Pause(int client);

/**
 * Resumes the player's timer.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_Resume(int client);

/**
 * Toggles the paused state of the player.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SKZ_TogglePause(int client);

/**
 * Gets the default movement style as set by convar kz_default_style.
 *
 * @return					The default movement style (see KZStyle enumeration).
 */
native KZStyle SKZ_GetDefaultStyle();

/**
 * Gets the current value of a player's option. Note that this
 * returns an int, whereas options use an enumerated tag.
 * Use the KZPlayer method map to simplify this caveat.
 *
 * @param client			Client entity index.
 * @param option			The SimpleKZ option (see KZOption enumeration).
 * @return					The current value of a player's option.
 */
native int SKZ_GetOption(int client, KZOption option);

/**
 * Sets the player's option value.
 *
 * @param client			Client entity index.
 * @param option			The SimpleKZ option (see KZOption enumeration).
 * @param optionValue		What to set the player's option to.
 * @noreturn
 */
native void SKZ_SetOption(int client, KZOption option, any optionValue); 