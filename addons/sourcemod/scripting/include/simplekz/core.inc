/* 	
	Simple KZ Core Include File
	
	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_core_included_
#endinput
#endif
#define _simplekz_core_included_

#include <movementapi>



/*===============================  Enumerations  ===============================*/

enum KZTimeType
{
	KZTimeType_Nub = 0, 
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
 * Called when a player has been set up e.g. options, timer etc.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnClientSetup(int client);

/**
 * Called when a player starts their timer.
 *
 * @param client		Client index.
 * @param course    	Course number e.g. 0=main, 1='bonus1' etc.
 * @param style			Player's movement style.
 * @noreturn
 */
forward void SKZ_OnTimerStart(int client, int course, KZStyle style);

/**
 * Called when a player ends their timer.
 *
 * @param client			Client index.
 * @param course    		Course number e.g. 0=main, 1='bonus1' etc.
 * @param style				Player's movement style.
 * @param time				Player's end time.
 * @param teleportsUsed		Number of teleports used by player.
 * @param theoreticalTime	Theoretical end time without using teleports.
 * @noreturn
 */
forward void SKZ_OnTimerEnd(int client, int course, KZStyle style, float time, int teleportsUsed, float theoreticalTime);

/**
 * Called when a player's timer has been force stopped.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnTimerForceStop(int client);

/**
 * Called when a player pauses.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnPause(int client);

/**
 * Called when a player resumes.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnResume(int client);

/**
 * Called when a player teleports to start.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnTeleportToStart(int client);

/**
 * Called when a player makes a checkpoint.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnCheckpoint(int client);

/**
 * Called when a player teleports to their checkpoint.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnTeleportToCheckpoint(int client);

/**
 * Called when a player undos teleport.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnUndoTeleport(int client);

/**
 * Called when a player changes an option.
 *
 * @param client		Client index.
 * @param option		Option that was changed.
 * @param newValue		New value of the option.
 * @noreturn
 */
forward void SKZ_OnChangeOption(int client, KZOption option, any newValue);



/*===============================  Natives  ===============================*/

/**
 * Gets whether client has been set up by SimpleKZ e.g. options, timer etc.
 *
 * @param client		Client index.
 * @return				Whether client has been set up.
 */
native KZStyle SKZ_IsClientSetUp(int client);

/**
 * Gets the default movement style as set by convar kz_default_style.
 *
 * @return				Default movement style.
 */
native KZStyle SKZ_GetDefaultStyle();

/**
 * Starts the player's timer for a course on the current map.
 *
 * @param client    	Client index.
 * @param course    	Course number e.g. 0=main, 1='bonus1' etc.
 * @noreturn
 */
native void SKZ_StartTimer(int client, int course);

/**
 * Ends the player's timer for a course on the current map.
 *
 * @param client    	Client index.
 * @param course    	Course number e.g. 0=main, 1='bonus1' etc.
 * @noreturn
 */
native void SKZ_EndTimer(int client, int course);

/**
 * Forces the player's timer to stop. Intended for run invalidation.
 *
 * @param client    	Client index.
 * @return				Whether player's timer was stopped.
 */
native bool SKZ_ForceStopTimer(int client);

/**
 * Forces all players' timers to stop. Intended for run invalidation.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_ForceStopTimerAll(int client);

/**
 * Gets whether or not the player's timer is running i.e. isn't 'stopped'.
 *
 * @param client    	Client index.
 * @return				Whether player's timer is running.
 */
native bool SKZ_GetTimerRunning(int client);

/**
 * Gets the course the player is currently running.
 *
 * @param client    	Client index.
 * @param course    	Course number e.g. 0=main, 1='bonus1' etc.
 */
native bool SKZ_GetCurrentCourse(int client);

/**
 * Gets whether the player is paused.
 *
 * @param client    	Client index.
 * @return				Whether player is paused.
 */
native bool SKZ_GetPaused(int client);

/**
 * Gets the player's current run time.
 *
 * @param client    	Client index.
 * @return				Player's current run time.
 */
native float SKZ_GetCurrentTime(int client);

/**
 * Gets the player's current checkpoint count.
 *
 * @param client    	Client index.
 * @return				Player's current checkpoint count.
 */
native int SKZ_GetCheckpointCount(int client);

/**
 * Teleports the player to start, or respawns them.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_TeleportToStart(int client);

/**
 * Set a new checkpoint at the player's current position.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_MakeCheckpoint(int client);

/**
 * Teleports the player to their last checkpoint.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_TeleportToCheckpoint(int client);

/**
 * Teleport the player to where they last teleported from.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_UndoTeleport(int client);

/**
 * Pause the player's timer and freeze them.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_Pause(int client);

/**
 * Resumes the player's timer and unfreezes them.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_Resume(int client);

/**
 * Toggles the paused state of the player.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_TogglePause(int client);

/**
 * Plays the error sound to the client if they have the option enabled.
 *
 * @param client		Client index.
 * @noreturn
 */
native void SKZ_PlayErrorSound(int client);

/**
 * Gets the current value of a player's option. Note that this
 * returns an int, whereas options use an enumerated tag.
 * Use the KZPlayer method map to simplify this caveat.
 *
 * @param client		Client index.
 * @param option		SimpleKZ option.
 * @return				Current value of option.
 */
native int SKZ_GetOption(int client, KZOption option);

/**
 * Sets the player's option value.
 *
 * @param client		Client index.
 * @param option		SimpleKZ option.
 * @param optionValue	New option value.
 * @noreturn
 */
native void SKZ_SetOption(int client, KZOption option, any optionValue);

/**
 * Gets whether player's last takeoff was a perfect bunnyhop as adjusted by SimpleKZ.
 *
 * @param client		Client index.
 * @return				Whether player's last takeoff was a SimpleKZ perfect b-hop.
 */
native bool SKZ_GetHitPerf(int client);

/**
 * Gets the player's horizontal speed at the time of their last takeoff
 * as adjusted by SimpleKZ.
 *
 * @param client		Client index.
 * @return				Player's last takeoff speed as adjusted by SimpleKZ.
 */
native float SKZ_GetTakeoffSpeed(int client);



/*===============================  Methodmap  ===============================*/

methodmap KZPlayer __nullable__ < MovementAPIPlayer {
	
	public KZPlayer(int id) {
		return view_as<KZPlayer>(id);
	}
	
	property int id {
		public get() {
			return view_as<int>(this);
		}
	}
	
	
	/*===============================  Functions  ===============================*/
	
	public void StartTimer(int course) {
		SKZ_StartTimer(this.id, course);
	}
	
	public void EndTimer(int course) {
		SKZ_EndTimer(this.id, course);
	}
	
	public bool ForceStopTimer() {
		return SKZ_ForceStopTimer(this.id);
	}
	
	public void TeleportToStart() {
		SKZ_TeleportToStart(this.id);
	}
	
	public void TeleportToCheckpoint() {
		SKZ_TeleportToCheckpoint(this.id);
	}
	
	public void UndoTeleport() {
		SKZ_UndoTeleport(this.id);
	}
	
	public void Pause() {
		SKZ_Pause(this.id);
	}
	
	public void Resume() {
		SKZ_Resume(this.id);
	}
	
	public void TogglePause() {
		SKZ_TogglePause(this.id);
	}
	
	public void PlayErrorSound() {
		SKZ_PlayErrorSound(this.id);
	}
	
	
	/*===============================  Timer Properties  ===============================*/
	
	property bool timerRunning {
		public get() {
			return SKZ_GetTimerRunning(this.id);
		}
	}
	
	property int currentCourse {
		public get() {
			return SKZ_GetCurrentCourse(this.id);
		}
	}
	
	property bool paused {
		public get() {
			return SKZ_GetPaused(this.id);
		}
		public set(bool pause) {
			if (pause) {
				this.Pause();
			}
			else {
				this.Resume();
			}
		}
	}
	
	property float currentTime {
		public get() {
			return SKZ_GetCurrentTime(this.id);
		}
	}
	
	property int checkpointCount {
		public get() {
			return SKZ_GetCheckpointCount(this.id);
		}
	}
	
	
	/*===============================  Options Properties  ===============================*/
	
	property KZStyle style {
		public get() {
			return view_as<KZStyle>(SKZ_GetOption(this.id, KZOption_Style));
		}
		public set(KZStyle value) {
			SKZ_SetOption(this.id, KZOption_Style, value);
		}
	}
	
	property KZShowingTPMenu showingTPMenu {
		public get() {
			return view_as<KZShowingTPMenu>(SKZ_GetOption(this.id, KZOption_ShowingTPMenu));
		}
		public set(KZShowingTPMenu value) {
			SKZ_SetOption(this.id, KZOption_ShowingTPMenu, value);
		}
	}
	
	property KZShowingInfoPanel showingInfoPanel {
		public get() {
			return view_as<KZShowingInfoPanel>(SKZ_GetOption(this.id, KZOption_ShowingInfoPanel));
		}
		public set(KZShowingInfoPanel value) {
			SKZ_SetOption(this.id, KZOption_ShowingInfoPanel, value);
		}
	}
	
	property KZShowingKeys showingKeys {
		public get() {
			return view_as<KZShowingKeys>(SKZ_GetOption(this.id, KZOption_ShowingKeys));
		}
		public set(KZShowingKeys value) {
			SKZ_SetOption(this.id, KZOption_ShowingKeys, value);
		}
	}
	
	property KZShowingPlayers showingPlayers {
		public get() {
			return view_as<KZShowingPlayers>(SKZ_GetOption(this.id, KZOption_ShowingPlayers));
		}
		public set(KZShowingPlayers value) {
			SKZ_SetOption(this.id, KZOption_ShowingPlayers, value);
		}
	}
	
	property KZShowingWeapon showingWeapon {
		public get() {
			return view_as<KZShowingWeapon>(SKZ_GetOption(this.id, KZOption_ShowingWeapon));
		}
		public set(KZShowingWeapon value) {
			SKZ_SetOption(this.id, KZOption_ShowingWeapon, value);
		}
	}
	
	property KZAutoRestart autoRestart {
		public get() {
			return view_as<KZAutoRestart>(SKZ_GetOption(this.id, KZOption_AutoRestart));
		}
		public set(KZAutoRestart value) {
			SKZ_SetOption(this.id, KZOption_AutoRestart, value);
		}
	}
	
	property KZSlayOnEnd slayOnEnd {
		public get() {
			return view_as<KZSlayOnEnd>(SKZ_GetOption(this.id, KZOption_SlayOnEnd));
		}
		public set(KZSlayOnEnd value) {
			SKZ_SetOption(this.id, KZOption_SlayOnEnd, value);
		}
	}
	
	property KZPistol pistol {
		public get() {
			return view_as<KZPistol>(SKZ_GetOption(this.id, KZOption_Pistol));
		}
		public set(KZPistol value) {
			SKZ_SetOption(this.id, KZOption_Pistol, value);
		}
	}
	
	property KZCheckpointMessages checkpointMessages {
		public get() {
			return view_as<KZCheckpointMessages>(SKZ_GetOption(this.id, KZOption_CheckpointMessages));
		}
		public set(KZCheckpointMessages value) {
			SKZ_SetOption(this.id, KZOption_CheckpointMessages, value);
		}
	}
	
	property KZCheckpointSounds checkpointSounds {
		public get() {
			return view_as<KZCheckpointSounds>(SKZ_GetOption(this.id, KZOption_CheckpointSounds));
		}
		public set(KZCheckpointSounds value) {
			SKZ_SetOption(this.id, KZOption_CheckpointSounds, value);
		}
	}
	
	property KZTeleportSounds teleportSounds {
		public get() {
			return view_as<KZTeleportSounds>(SKZ_GetOption(this.id, KZOption_TeleportSounds));
		}
		public set(KZTeleportSounds value) {
			SKZ_SetOption(this.id, KZOption_TeleportSounds, value);
		}
	}
	
	property KZErrorSounds errorSounds {
		public get() {
			return view_as<KZErrorSounds>(SKZ_GetOption(this.id, KZOption_ErrorSounds));
		}
		public set(KZErrorSounds value) {
			SKZ_SetOption(this.id, KZOption_ErrorSounds, value);
		}
	}
	
	property KZTimerText timerText {
		public get() {
			return view_as<KZTimerText>(SKZ_GetOption(this.id, KZOption_TimerText));
		}
		public set(KZTimerText value) {
			SKZ_SetOption(this.id, KZOption_TimerText, value);
		}
	}
	
	property KZSpeedText speedText {
		public get() {
			return view_as<KZSpeedText>(SKZ_GetOption(this.id, KZOption_SpeedText));
		}
		public set(KZSpeedText value) {
			SKZ_SetOption(this.id, KZOption_SpeedText, value);
		}
	}
	
	
	/*===============================  Other Properties  ===============================*/
	
	property bool skzHitPerf {
		public get() {
			return SKZ_GetHitPerf(this.id);
		}
	}
	
	property float skzTakeoffSpeed {
		public get() {
			return SKZ_GetTakeoffSpeed(this.id);
		}
	}
}



/*===============================  Dependency  ===============================*/

public SharedPlugin __pl_simplekz_core = 
{
	name = "simplekz-core", 
	file = "simplekz-core.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_simplekz_core_SetNTVOptional()
{
	MarkNativeAsOptional("SKZ_StartTimer");
	MarkNativeAsOptional("SKZ_EndTimer");
	MarkNativeAsOptional("SKZ_ForceStopTimer");
	MarkNativeAsOptional("SKZ_ForceStopTimerAll");
	MarkNativeAsOptional("SKZ_TeleportToStart");
	MarkNativeAsOptional("SKZ_MakeCheckpoint");
	MarkNativeAsOptional("SKZ_TeleportToCheckpoint");
	MarkNativeAsOptional("SKZ_UndoTeleport");
	MarkNativeAsOptional("SKZ_Pause");
	MarkNativeAsOptional("SKZ_Resume");
	MarkNativeAsOptional("SKZ_TogglePause");
	MarkNativeAsOptional("SKZ_PlayErrorSound");
	
	MarkNativeAsOptional("SKZ_GetDefaultStyle");
	MarkNativeAsOptional("SKZ_GetTimerRunning");
	MarkNativeAsOptional("SKZ_GetCurrentCourse");
	MarkNativeAsOptional("SKZ_GetPaused");
	MarkNativeAsOptional("SKZ_GetCurrentTime");
	MarkNativeAsOptional("SKZ_GetCheckpointCount");
	MarkNativeAsOptional("SKZ_GetOption");
	MarkNativeAsOptional("SKZ_SetOption");
	MarkNativeAsOptional("SKZ_GetHitPerf");
	MarkNativeAsOptional("SKZ_GetTakeoffSpeed");
}
#endif