/* 	
	SimpleKZ Core Include File
	
	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_core_included_
#endinput
#endif
#define _simplekz_core_included_

#include <movementapi>



// =========================  ENUMERATIONS  ========================= //

enum
{
	TimeType_Nub = 0, 
	TimeType_Pro, 
	TimeType_Theoretical, 
	TIMETYPE_COUNT
}

enum
{
	StyleCVar_Accelerate = 0, 
	StyleCVar_Friction, 
	StyleCVar_AirAccelerate, 
	StyleCVar_LadderScaleSpeed, 
	StyleCVar_MaxVelocity, 
	StyleCVar_Gravity, 
	StyleCVar_EnableBunnyhopping, 
	StyleCVar_AutoBunnyhopping, 
	StyleCVar_StaminaMax, 
	StyleCVar_StaminaLandCost, 
	StyleCVar_StaminaJumpCost, 
	StyleCVar_StaminaRecoveryRate, 
	StyleCVar_MaxSpeed, 
	StyleCVar_WaterAccelerate, 
	StyleCVar_TimeBetweenDucks, 
	StyleCVar_AccelerateUseWeaponSpeed, 
	STYLECVAR_COUNT
}

enum
{
	MapPrefix_Other, 
	MapPrefix_KZPro, 
	MAPPREFIX_COUNT
}

enum Option
{
	Option_Style = 0, 
	Option_ShowingTPMenu, 
	Option_ShowingInfoPanel, 
	Option_ShowingKeys, 
	Option_ShowingPlayers, 
	Option_ShowingWeapon, 
	Option_AutoRestart, 
	Option_SlayOnEnd, 
	Option_Pistol, 
	Option_CheckpointMessages, 
	Option_CheckpointSounds, 
	Option_TeleportSounds, 
	Option_ErrorSounds, 
	Option_TimerText, 
	Option_SpeedText, 
	OPTION_COUNT
}

enum
{
	Style_Standard = 0, 
	Style_Legacy, 
	Style_Competitive, 
	STYLE_COUNT
}

enum
{
	ShowingTPMenu_Disabled = 0, 
	ShowingTPMenu_Enabled, 
	SHOWINGTPMENU_COUNT
}

enum
{
	ShowingInfoPanel_Disabled = 0, 
	ShowingInfoPanel_Enabled, 
	SHOWINGINFOPANEL_COUNT
}

enum
{
	ShowingKeys_Spectating = 0, 
	ShowingKeys_Always, 
	ShowingKeys_Disabled, 
	SHOWINGKEYS_COUNT
}

enum
{
	ShowingPlayers_Disabled = 0, 
	ShowingPlayers_Enabled, 
	SHOWINGPLAYERS_COUNT
}

enum
{
	ShowingWeapon_Disabled = 0, 
	ShowingWeapon_Enabled, 
	SHOWINGWEAPON_COUNT
}

enum
{
	AutoRestart_Disabled = 0, 
	AutoRestart_Enabled, 
	AUTORESTART_COUNT
}

enum
{
	SlayOnEnd_Disabled = 0, 
	SlayOnEnd_Enabled, 
	SLAYONEND_COUNT
}

enum
{
	Pistol_USP = 0, 
	Pistol_Glock, 
	Pistol_P250, 
	Pistol_Dualies, 
	Pistol_Deagle, 
	Pistol_CZ75A, 
	Pistol_FiveSeveN, 
	Pistol_Tec9, 
	PISTOL_COUNT
}

enum
{
	CheckpointMessages_Disabled = 0, 
	CheckpointMessages_Enabled, 
	CHECKPOINTMESSAGES_COUNT
}

enum
{
	CheckpointSounds_Disabled = 0, 
	CheckpointSounds_Enabled, 
	CHECKPOINTSOUNDS_COUNT
}

enum
{
	TeleportSounds_Disabled = 0, 
	TeleportSounds_Enabled, 
	TELEPORTSOUNDS_COUNT
}

enum
{
	ErrorSounds_Disabled = 0, 
	ErrorSounds_Enabled, 
	ERRORSOUNDS_COUNT
}

enum
{
	TimerText_Disabled = 0, 
	TimerText_InfoPanel, 
	TimerText_Bottom, 
	TimerText_Top, 
	TIMERTEXT_COUNT
}

enum
{
	SpeedText_Disabled = 0, 
	SpeedText_InfoPanel, 
	SpeedText_Bottom, 
	SPEEDTEXT_COUNT
}



// =========================  TRANSLATION PHRASES  ========================= //

stock char gC_StylePhrases[STYLE_COUNT][] = 
{
	"Style - Standard", 
	"Style - Legacy", 
	"Style - Competitive"
};

stock char gC_TimeTypePhrases[TIMETYPE_COUNT][] = 
{
	"Time Type - Nub", 
	"Time Type - Pro", 
	"Time Type - Theoretical"
};



// =========================  FORWARDS  ========================= //

/**
 * Called when a player has been set up e.g. options, timer etc.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnClientSetup(int client);

/**
 * Called when a player changes an option.
 *
 * @param client		Client index.
 * @param option		Option that was changed.
 * @param newValue		New value of the option.
 * @noreturn
 */
forward void SKZ_OnOptionChanged(int client, Option option, int newValue);

/**
 * Called when a player starts their timer.
 *
 * @param client		Client index.
 * @param course    	Course number e.g. 0=main, 1='bonus1' etc.
 * @param style			Player's movement style.
 * @return				Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnTimerStart(int client, int course, int style);

/**
 * Called when a player has started their timer.
 *
 * @param client		Client index.
 * @param course    	Course number e.g. 0=main, 1='bonus1' etc.
 * @param style			Player's movement style.
 * @noreturn
 */
forward void SKZ_OnTimerStart_Post(int client, int course, int style);

/**
 * Called when a player ends their timer.
 *
 * @param client			Client index.
 * @param course    		Course number e.g. 0=main, 1='bonus1' etc.
 * @param style				Player's movement style.
 * @param time				Player's end time.
 * @param teleportsUsed		Number of teleports used by player.
 * @param theoreticalTime	Theoretical end time without teleports.
 * @return					Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnTimerEnd(int client, int course, int style, float time, int teleportsUsed, float theoreticalTime);

/**
 * Called when a player has ended their timer.
 *
 * @param client			Client index.
 * @param course    		Course number e.g. 0=main, 1='bonus1' etc.
 * @param style				Player's movement style.
 * @param time				Player's end time.
 * @param teleportsUsed		Number of teleports used by player.
 * @param theoreticalTime	Theoretical end time without teleports.
 * @noreturn
 */
forward void SKZ_OnTimerEnd_Post(int client, int course, int style, float time, int teleportsUsed, float theoreticalTime);

/**
 * Called when a player's timer has been forcefully stopped.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnTimerStopped(int client);

/**
 * Called when a player pauses.
 *
 * @param client		Client index.
 * @return				Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnPause(int client);

/**
 * Called when a player has paused.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnPause_Post(int client);

/**
 * Called when a player resumes.
 *
 * @param client		Client index.
 * @return				Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnResume(int client);

/**
 * Called when a player has resumed.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnResume_Post(int client);

/**
 * Called when a player makes a checkpoint.
 *
 * @param client		Client index.
 * @return				Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnMakeCheckpoint(int client);

/**
 * Called when a player has made a checkpoint.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnMakeCheckpoint_Post(int client);

/**
 * Called when a player teleports to their checkpoint.
 *
 * @param client		Client index.
 * @return				Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnTeleportToCheckpoint(int client);

/**
 * Called when a player has teleported to their checkpoint.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnTeleportToCheckpoint_Post(int client);

/**
 * Called when a player teleports to start.
 *
 * @param client		Client index.
 * @return				Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnTeleportToStart(int client);

/**
 * Called when a player has teleported to start.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnTeleportToStart_Post(int client);

/**
 * Called when a player undoes a teleport.
 *
 * @param client		Client index.
 * @return				Plugin_Handled or Plugin_Stop to block, Plugin_Continue to proceed.
 */
forward Action SKZ_OnUndoTeleport(int client);

/**
 * Called when a player has undone a teleport.
 *
 * @param client		Client index.
 * @noreturn
 */
forward void SKZ_OnUndoTeleport_Post(int client);



// =========================  NATIVES  ========================= //

/**
 * Gets whether client has been set up by SimpleKZ e.g. options, timer etc.
 *
 * @param client		Client index.
 * @return				Whether client has been set up.
 */
native bool SKZ_IsClientSetUp(int client);

/**
 * Gets the default movement style as set by convar _default_style.
 *
 * @return				Default movement style.
 */
native int SKZ_GetDefaultStyle();

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
native bool SKZ_StopTimer(int client);

/**
 * Forces all players' timers to stop. Intended for run invalidation.
 *
 * @param client    	Client index.
 * @noreturn
 */
native void SKZ_StopTimerAll(int client);

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
 * Gets the current value of a player's option.
 *
 * @param client		Client index.
 * @param option		SimpleKZ option.
 * @return				Current value of option.
 */
native int SKZ_GetOption(int client, Option option);

/**
 * Sets the player's option value.
 *
 * @param client		Client index.
 * @param option		SimpleKZ option.
 * @param optionValue	New option value.
 * @param printMessage	Whether to print option change messages.
 * @noreturn
 */
native void SKZ_SetOption(int client, Option option, any optionValue, bool printMessage = false);

/**
 * Gets whether player's last takeoff was a perfect bunnyhop as adjusted by SimpleKZ.
 *
 * @param client		Client index.
 * @return				Whether player's last takeoff was a SimpleKZ perfect b-hop.
 */
native bool SKZ_GetHitPerf(int client);

/**
 * Gets the player's horizontal speed at the time of their last takeoff as adjusted by SimpleKZ.
 *
 * @param client		Client index.
 * @return				Player's last takeoff speed as adjusted by SimpleKZ.
 */
native float SKZ_GetTakeoffSpeed(int client);

/**
 * Prints a message to a client's chat, formatting colours and optionally 
 * adding the chat prefix. If using the chat prefix, specify a colour at 
 * the beginning of the message.
 *
 * @param client		Client index.
 * @param prefix		Whether to add the chat prefix.
 * @param format		Formatting rules.
 * @param any			Variable number of format parameters.
 * @noreturn
 */
native int SKZ_PrintToChat(int client, bool prefix, const char[] format, any...);


/**
 * Prints a message to all clients' chat, formatting colours and optionally 
 * adding the chat prefix. If using the chat prefix, specify a colour at 
 * the beginning of the message.
 *
 * @param client		Client index.
 * @param prefix		Whether to add the chat prefix.
 * @param format		Formatting rules.
 * @param any			Variable number of format parameters.
 * @noreturn
 */
stock void SKZ_PrintToChatAll(bool prefix, const char[] format, any...)
{
	char buffer[256];
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			SetGlobalTransTarget(client);
			VFormat(buffer, sizeof(buffer), format, 3);
			SKZ_PrintToChat(client, prefix, buffer);
		}
	}
}



// =========================  METHODMAP  ========================= //

methodmap KZPlayer __nullable__ < MovementAPIPlayer {
	
	public KZPlayer(int id) {
		return view_as<KZPlayer>(id);
	}
	
	property int id {
		public get() {
			return view_as<int>(this);
		}
	}
	
	
	// =========================  TIMER  ========================= //
	
	public void StartTimer(int course) {
		SKZ_StartTimer(this.id, course);
	}
	
	public void EndTimer(int course) {
		SKZ_EndTimer(this.id, course);
	}
	
	public bool StopTimer() {
		return SKZ_StopTimer(this.id);
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
	
	
	// =========================  OPTIONS  ========================= //
	
	public int GetOption(Option option) {
		return SKZ_GetOption(this.id, option);
	}
	
	public void SetOption(Option option, int optionValue, bool printMessage = false) {
		SKZ_SetOption(this.id, option, optionValue, printMessage);
	}
	
	property int style {
		public get() {
			return this.GetOption(Option_Style);
		}
		public set(int value) {
			this.SetOption(Option_Style, value);
		}
	}
	
	property int showingTPMenu {
		public get() {
			return this.GetOption(Option_ShowingTPMenu);
		}
		public set(int value) {
			this.SetOption(Option_ShowingTPMenu, value);
		}
	}
	
	property int showingInfoPanel {
		public get() {
			return this.GetOption(Option_ShowingInfoPanel);
		}
		public set(int value) {
			this.SetOption(Option_ShowingInfoPanel, value);
		}
	}
	
	property int showingKeys {
		public get() {
			return this.GetOption(Option_ShowingKeys);
		}
		public set(int value) {
			this.SetOption(Option_ShowingKeys, value);
		}
	}
	
	property int showingPlayers {
		public get() {
			return this.GetOption(Option_ShowingPlayers);
		}
		public set(int value) {
			this.SetOption(Option_ShowingPlayers, value);
		}
	}
	
	property int showingWeapon {
		public get() {
			return this.GetOption(Option_ShowingWeapon);
		}
		public set(int value) {
			this.SetOption(Option_ShowingWeapon, value);
		}
	}
	
	property int autoRestart {
		public get() {
			return this.GetOption(Option_AutoRestart);
		}
		public set(int value) {
			this.SetOption(Option_AutoRestart, value);
		}
	}
	
	property int slayOnEnd {
		public get() {
			return this.GetOption(Option_SlayOnEnd);
		}
		public set(int value) {
			this.SetOption(Option_SlayOnEnd, value);
		}
	}
	
	property int pistol {
		public get() {
			return this.GetOption(Option_Pistol);
		}
		public set(int value) {
			this.SetOption(Option_Pistol, value);
		}
	}
	
	property int checkpointMessages {
		public get() {
			return this.GetOption(Option_CheckpointMessages);
		}
		public set(int value) {
			this.SetOption(Option_CheckpointMessages, value);
		}
	}
	
	property int checkpointSounds {
		public get() {
			return this.GetOption(Option_CheckpointSounds);
		}
		public set(int value) {
			this.SetOption(Option_CheckpointSounds, value);
		}
	}
	
	property int teleportSounds {
		public get() {
			return this.GetOption(Option_TeleportSounds);
		}
		public set(int value) {
			this.SetOption(Option_TeleportSounds, value);
		}
	}
	
	property int errorSounds {
		public get() {
			return this.GetOption(Option_ErrorSounds);
		}
		public set(int value) {
			this.SetOption(Option_ErrorSounds, value);
		}
	}
	
	property int timerText {
		public get() {
			return this.GetOption(Option_TimerText);
		}
		public set(int value) {
			this.SetOption(Option_TimerText, value);
		}
	}
	
	property int speedText {
		public get() {
			return this.GetOption(Option_SpeedText);
		}
		public set(int value) {
			this.SetOption(Option_SpeedText, value);
		}
	}
	
	
	// =========================  MISC  ========================= //
	
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
	
	property bool valid {
		public get() {
			return IsValidClient(this.id);
		}
	}
	
	property bool fake {
		public get() {
			return IsFakeClient(this.id);
		}
	}
	
	property bool alive {
		public get() {
			return IsPlayerAlive(this.id);
		}
	}
	
	property bool hasSpecTarget {
		public get() {
			return IsSpectatingSomeone(this.id);
		}
	}
	
	property int specTarget {
		public get() {
			return GetObserverTarget(this.id);
		}
	}
}



// =========================  DEPENDENCY  ========================= //

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
	MarkNativeAsOptional("SKZ_StopTimer");
	MarkNativeAsOptional("SKZ_StopTimerAll");
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