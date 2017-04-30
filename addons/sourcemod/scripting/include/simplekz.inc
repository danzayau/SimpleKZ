/* 	
	SimpleKZ Stocks

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
 * @param client				Entity index
 * @return						True if the client is valid
 */
stock bool IsValidClient(int client)
{
	return client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}

/**
 * Returns the max of two float values.
 *
 * @param value1				First value
 * @param value2				Second value
 * @return						The greater of the two values, or their value if they are equal
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
 * @param input					Input string
 * @param output				Output buffer
 * @param size					Maximum size of output
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
 * Gets the player that the client is spectating.
 *
 * @param client				Spectating client.
 * @return						Client entity index of player they are spectating.
 */
stock int GetSpectatedClient(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

/**
 * Emits a sound to other players that are spectating the client.
 *
 * @param client				Client being spectated.
 * @param sound					Sound to play.
 * @noreturn
 */
stock void EmitSoundToClientSpectators(int client, const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetSpectatedClient(i) == client)
		{
			EmitSoundToClient(i, sound);
		}
	}
} 