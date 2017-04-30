/* 	
	Simple KZ Helper Include File

	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_included_
#endinput
#endif
#define _simplekz_included_



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