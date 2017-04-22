/* 	
	Simple KZ Official Include File

	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_included_
#endinput
#endif
#define _simplekz_included_

#include <movement>
#include <simplekz/core>
#include <simplekz/localdb>
#include <simplekz/localranks>



/*===============================  Stocks  ===============================*/

/**
 * Presents a time float (seconds) as a string e.g. 01:23.45 or 01:23:34.56.
 *
 * @param time				Time in seconds
 * @return					Formatted time
 */
stock char[] SKZ_FormatTime(float time)
{
	char formattedTime[12];
	
	int roundedTime = RoundFloat(time * 100); // Time rounded to number of centiseconds
	
	int centiseconds = roundedTime % 100;
	roundedTime = (roundedTime - centiseconds) / 100;
	int seconds = roundedTime % 60;
	roundedTime = (roundedTime - seconds) / 60;
	int minutes = roundedTime % 60;
	roundedTime = (roundedTime - minutes) / 60;
	int hours = roundedTime;
	
	if (hours == 0)
	{
		FormatEx(formattedTime, sizeof(formattedTime), "%02d:%02d.%02d", minutes, seconds, centiseconds);
	}
	else
	{
		FormatEx(formattedTime, sizeof(formattedTime), "%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds);
	}
	return formattedTime;
}

/**
 * Checks if the client is a valid client entity index, and if they are in-game.
 *
 * @param client			Entity index
 * @return					True if the client is valid
 */
stock bool IsValidClient(int client)
{
	return client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}

/**
 * Returns the max of two float values.
 *
 * @param value1			First value
 * @param value2			Second value
 * @return					The greater of the two values, or their value if they are equal
 */
stock float FloatMax(float value1, float value2)
{
	if (value1 >= value2)
	{
		return value1;
	}
	return value2;
}

/**
 * Outputs the string in all lower case.
 *
 * @param input				Input string
 * @param output			Output buffer
 * @param size				Maximum size of output
 * @noreturn
 */
stock void String_ToLower(const char[] input, char[] output, int size)
{
	size--;
	int i = 0;
	while (input[i] != '\0' && i < size)
	{
		output[i] = CharToLower(input[i]);
		i++;
	}
	output[i] = '\0';
}

/**
 * Precaches a sound file.
 *
 * @param relativeSoundpath	Relative sound path (starts with *)
 * @noreturn
 */
stock void FakePrecacheSound(const char[] relativeSoundPath)
{
	AddToStringTable(FindStringTable("soundprecache"), relativeSoundPath);
}



/*===============================  Methodmap  ===============================*/

methodmap KZPlayer __nullable__ < MovementPlayer
{
	public KZPlayer(int id)
	{
		return view_as<KZPlayer>(id);
	}
	
	property int id
	{
		public get()
		{
			return view_as<int>(this);
		}
	}
	
	
	/*===============================  Functions  ===============================*/
	
	public void StartTimer(int course)
	{
		SKZ_StartTimer(this.id, course);
	}
	
	public void EndTimer(int course)
	{
		SKZ_EndTimer(this.id, course);
	}
	
	public bool ForceStopTimer()
	{
		return SKZ_ForceStopTimer(this.id);
	}
	
	public void TeleportToStart()
	{
		SKZ_TeleportToStart(this.id);
	}
	
	public void TeleportToCheckpoint()
	{
		SKZ_TeleportToCheckpoint(this.id);
	}
	
	public void UndoTeleport()
	{
		SKZ_UndoTeleport(this.id);
	}
	
	public void Pause()
	{
		SKZ_Pause(this.id);
	}
	
	public void Resume()
	{
		SKZ_Resume(this.id);
	}
	
	public void TogglePause()
	{
		SKZ_TogglePause(this.id);
	}
	
	public void PlayErrorSound()
	{
		SKZ_PlayErrorSound(this.id);
	}
	
	
	/*===============================  Timer Properties  ===============================*/
	
	property bool timerRunning
	{
		public get()
		{
			return SKZ_GetTimerRunning(this.id);
		}
	}
	
	property int currentCourse
	{
		public get()
		{
			return SKZ_GetCurrentCourse(this.id);
		}
	}
	
	property bool paused
	{
		public get()
		{
			return SKZ_GetPaused(this.id);
		}
		public set(bool pause)
		{
			if (pause)
			{
				this.Pause();
			}
			else
			{
				this.Resume();
			}
		}
	}
	
	property float currentTime
	{
		public get()
		{
			return SKZ_GetCurrentTime(this.id);
		}
	}
	
	property int checkpointCount
	{
		public get()
		{
			return SKZ_GetCheckpointCount(this.id);
		}
	}
	
	
	/*===============================  Options Properties  ===============================*/
	
	property KZStyle style
	{
		public get()
		{
			return view_as<KZStyle>(SKZ_GetOption(this.id, KZOption_Style));
		}
		public set(KZStyle value)
		{
			SKZ_SetOption(this.id, KZOption_Style, value);
		}
	}
	
	property KZShowingTPMenu showingTPMenu
	{
		public get()
		{
			return view_as<KZShowingTPMenu>(SKZ_GetOption(this.id, KZOption_ShowingTPMenu));
		}
		public set(KZShowingTPMenu value)
		{
			SKZ_SetOption(this.id, KZOption_ShowingTPMenu, value);
		}
	}
	
	property KZShowingInfoPanel showingInfoPanel
	{
		public get()
		{
			return view_as<KZShowingInfoPanel>(SKZ_GetOption(this.id, KZOption_ShowingInfoPanel));
		}
		public set(KZShowingInfoPanel value)
		{
			SKZ_SetOption(this.id, KZOption_ShowingInfoPanel, value);
		}
	}
	
	property KZShowingKeys showingKeys
	{
		public get()
		{
			return view_as<KZShowingKeys>(SKZ_GetOption(this.id, KZOption_ShowingKeys));
		}
		public set(KZShowingKeys value)
		{
			SKZ_SetOption(this.id, KZOption_ShowingKeys, value);
		}
	}
	
	property KZShowingPlayers showingPlayers
	{
		public get()
		{
			return view_as<KZShowingPlayers>(SKZ_GetOption(this.id, KZOption_ShowingPlayers));
		}
		public set(KZShowingPlayers value)
		{
			SKZ_SetOption(this.id, KZOption_ShowingPlayers, value);
		}
	}
	
	property KZShowingWeapon showingWeapon
	{
		public get()
		{
			return view_as<KZShowingWeapon>(SKZ_GetOption(this.id, KZOption_ShowingWeapon));
		}
		public set(KZShowingWeapon value)
		{
			SKZ_SetOption(this.id, KZOption_ShowingWeapon, value);
		}
	}
	
	property KZAutoRestart autoRestart
	{
		public get()
		{
			return view_as<KZAutoRestart>(SKZ_GetOption(this.id, KZOption_AutoRestart));
		}
		public set(KZAutoRestart value)
		{
			SKZ_SetOption(this.id, KZOption_AutoRestart, value);
		}
	}
	
	property KZSlayOnEnd slayOnEnd
	{
		public get()
		{
			return view_as<KZSlayOnEnd>(SKZ_GetOption(this.id, KZOption_SlayOnEnd));
		}
		public set(KZSlayOnEnd value)
		{
			SKZ_SetOption(this.id, KZOption_SlayOnEnd, value);
		}
	}
	
	property KZPistol pistol
	{
		public get()
		{
			return view_as<KZPistol>(SKZ_GetOption(this.id, KZOption_Pistol));
		}
		public set(KZPistol value)
		{
			SKZ_SetOption(this.id, KZOption_Pistol, value);
		}
	}
	
	property KZCheckpointMessages checkpointMessages
	{
		public get()
		{
			return view_as<KZCheckpointMessages>(SKZ_GetOption(this.id, KZOption_CheckpointMessages));
		}
		public set(KZCheckpointMessages value)
		{
			SKZ_SetOption(this.id, KZOption_CheckpointMessages, value);
		}
	}
	
	property KZCheckpointSounds checkpointSounds
	{
		public get()
		{
			return view_as<KZCheckpointSounds>(SKZ_GetOption(this.id, KZOption_CheckpointSounds));
		}
		public set(KZCheckpointSounds value)
		{
			SKZ_SetOption(this.id, KZOption_CheckpointSounds, value);
		}
	}
	
	property KZTeleportSounds teleportSounds
	{
		public get()
		{
			return view_as<KZTeleportSounds>(SKZ_GetOption(this.id, KZOption_TeleportSounds));
		}
		public set(KZTeleportSounds value)
		{
			SKZ_SetOption(this.id, KZOption_TeleportSounds, value);
		}
	}
	
	property KZErrorSounds errorSounds
	{
		public get()
		{
			return view_as<KZErrorSounds>(SKZ_GetOption(this.id, KZOption_ErrorSounds));
		}
		public set(KZErrorSounds value)
		{
			SKZ_SetOption(this.id, KZOption_ErrorSounds, value);
		}
	}
	
	property KZTimerText timerText
	{
		public get()
		{
			return view_as<KZTimerText>(SKZ_GetOption(this.id, KZOption_TimerText));
		}
		public set(KZTimerText value)
		{
			SKZ_SetOption(this.id, KZOption_TimerText, value);
		}
	}
	
	property KZSpeedText speedText
	{
		public get()
		{
			return view_as<KZSpeedText>(SKZ_GetOption(this.id, KZOption_SpeedText));
		}
		public set(KZSpeedText value)
		{
			SKZ_SetOption(this.id, KZOption_SpeedText, value);
		}
	}
	
	
	/*===============================  Other Properties  ===============================*/
	
	property bool hitPerf
	{
		public get()
		{
			return SKZ_GetHitPerf(this.id);
		}
	}
	
	property int db_playerID
	{
		public get()
		{
			return SKZ_GetPlayerID(this.id);
		}
	}
} 