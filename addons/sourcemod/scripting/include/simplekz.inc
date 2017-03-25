/* 	Simple KZ Official Include File
	Author: DanZay
	
	Plugin Version: 0.10.2
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_included_
#endinput
#endif
#define _simplekz_included_

#include <simplekz/core>
#include <simplekz/localdb>
#include <simplekz/localranks>



/*===============================  Stocks  ===============================*/

/**
 * Presents a time float (seconds) as a string e.g. 01:23.45 or 01:23:34.56.
 *
 * @param time				Time in seconds.
 * @return					Formatted time.
 */
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



/*===============================  Methodmap  ===============================*/

methodmap KZPlayer __nullable__ {
	public KZPlayer(int id) {
		return view_as<KZPlayer>(id);
	}
	
	property int id {
		public get() {
			return view_as<int>(this);
		}
	}
	
	
	/*===============================  Timer Functions  ===============================*/
	
	public void StartTimer(int course) {
		SimpleKZ_StartTimer(this.id, course);
	}
	
	public void EndTimer(int course) {
		SimpleKZ_EndTimer(this.id, course);
	}
	
	public bool ForceStopTimer() {
		return SimpleKZ_ForceStopTimer(this.id);
	}
	
	public void TeleportToStart() {
		SimpleKZ_TeleportToStart(this.id);
	}
	
	public void TeleportToCheckpoint() {
		SimpleKZ_TeleportToCheckpoint(this.id);
	}
	
	public void UndoTeleport() {
		SimpleKZ_UndoTeleport(this.id);
	}
	
	public void Pause() {
		SimpleKZ_Pause(this.id);
	}
	
	public void Resume() {
		SimpleKZ_Resume(this.id);
	}
	
	public void TogglePause() {
		SimpleKZ_TogglePause(this.id);
	}
	
	
	/*===============================  Timer Properties  ===============================*/
	
	property bool timerRunning {
		public get() {
			return SimpleKZ_GetTimerRunning(this.id);
		}
	}
	
	property int currentCourse {
		public get() {
			return SimpleKZ_GetCurrentCourse(this.id);
		}
	}
	
	property bool paused {
		public get() {
			return SimpleKZ_GetCurrentCourse(this.id);
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
			return SimpleKZ_GetCurrentTime(this.id);
		}
	}
	
	property int checkpointCount {
		public get() {
			return SimpleKZ_GetCheckpointCount(this.id);
		}
	}
	
	
	/*===============================  Options Properties  ===============================*/
	
	property KZStyle style {
		public get() {
			return view_as<KZStyle>(SimpleKZ_GetOption(this.id, KZOption_Style));
		}
		public set(KZStyle value) {
			SimpleKZ_SetOption(this.id, KZOption_Style, value);
		}
	}
	
	property KZShowingTeleportMenu showingTeleportMenu {
		public get() {
			return view_as<KZShowingTeleportMenu>(SimpleKZ_GetOption(this.id, KZOption_ShowingTeleportMenu));
		}
		public set(KZShowingTeleportMenu value) {
			SimpleKZ_SetOption(this.id, KZOption_ShowingTeleportMenu, value);
		}
	}
	
	property KZShowingInfoPanel showingInfoPanel {
		public get() {
			return view_as<KZShowingInfoPanel>(SimpleKZ_GetOption(this.id, KZOption_ShowingInfoPanel));
		}
		public set(KZShowingInfoPanel value) {
			SimpleKZ_SetOption(this.id, KZOption_ShowingInfoPanel, value);
		}
	}
	
	property KZShowingKeys showingKeys {
		public get() {
			return view_as<KZShowingKeys>(SimpleKZ_GetOption(this.id, KZOption_ShowingKeys));
		}
		public set(KZShowingKeys value) {
			SimpleKZ_SetOption(this.id, KZOption_ShowingKeys, value);
		}
	}
	
	property KZShowingPlayers showingPlayers {
		public get() {
			return view_as<KZShowingPlayers>(SimpleKZ_GetOption(this.id, KZOption_ShowingPlayers));
		}
		public set(KZShowingPlayers value) {
			SimpleKZ_SetOption(this.id, KZOption_ShowingPlayers, value);
		}
	}
	
	property KZShowingWeapon showingWeapon {
		public get() {
			return view_as<KZShowingWeapon>(SimpleKZ_GetOption(this.id, KZOption_ShowingWeapon));
		}
		public set(KZShowingWeapon value) {
			SimpleKZ_SetOption(this.id, KZOption_ShowingWeapon, value);
		}
	}
	
	property KZAutoRestart autoRestart {
		public get() {
			return view_as<KZAutoRestart>(SimpleKZ_GetOption(this.id, KZOption_AutoRestart));
		}
		public set(KZAutoRestart value) {
			SimpleKZ_SetOption(this.id, KZOption_AutoRestart, value);
		}
	}
	
	property KZSlayOnEnd slayOnEnd {
		public get() {
			return view_as<KZSlayOnEnd>(SimpleKZ_GetOption(this.id, KZOption_SlayOnEnd));
		}
		public set(KZSlayOnEnd value) {
			SimpleKZ_SetOption(this.id, KZOption_SlayOnEnd, value);
		}
	}
	
	property KZPistol pistol {
		public get() {
			return view_as<KZPistol>(SimpleKZ_GetOption(this.id, KZOption_Pistol));
		}
		public set(KZPistol value) {
			SimpleKZ_SetOption(this.id, KZOption_Pistol, value);
		}
	}
	
	property KZCheckpointMessages checkpointMessages {
		public get() {
			return view_as<KZCheckpointMessages>(SimpleKZ_GetOption(this.id, KZOption_CheckpointMessages));
		}
		public set(KZCheckpointMessages value) {
			SimpleKZ_SetOption(this.id, KZOption_CheckpointMessages, value);
		}
	}
	
	property KZCheckpointSounds checkpointSounds {
		public get() {
			return view_as<KZCheckpointSounds>(SimpleKZ_GetOption(this.id, KZOption_CheckpointSounds));
		}
		public set(KZCheckpointSounds value) {
			SimpleKZ_SetOption(this.id, KZOption_CheckpointSounds, value);
		}
	}
	
	property KZTeleportSounds teleportSounds {
		public get() {
			return view_as<KZTeleportSounds>(SimpleKZ_GetOption(this.id, KZOption_TeleportSounds));
		}
		public set(KZTeleportSounds value) {
			SimpleKZ_SetOption(this.id, KZOption_TeleportSounds, value);
		}
	}
	
	property KZTimerText timerText {
		public get() {
			return view_as<KZTimerText>(SimpleKZ_GetOption(this.id, KZOption_TimerText));
		}
		public set(KZTimerText value) {
			SimpleKZ_SetOption(this.id, KZOption_TimerText, value);
		}
	}
	
	
	/*===============================  Other Properties  ===============================*/
	
	property bool hitPerf {
		public get() {
			return SimpleKZ_GetHitPerf(this.id);
		}
	}
	
	property int db_playerID {
		public get() {
			return SimpleKZ_GetPlayerID(this.id);
		}
	}
} 