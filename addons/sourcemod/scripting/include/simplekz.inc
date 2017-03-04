/* 	Simple KZ Official Include Files
	Author: DanZay
	
	Plugin Version: 0.9.1
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_included_
#endinput
#endif
#define _simplekz_included_

#include <simplekz/core>
#include <simplekz/ranks>



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

/**
 * Converts a time float (seconds) to an integer (milliseconds).
 *
 * @param time				Time in seconds.
 * @return					Number of milliseconds.
 */
stock int SimpleKZ_TimeFloatToInt(float time) {
	return RoundFloat(time * 1000.0);
}

/**
 * Converts a time integer (milliseconds) to a float (seconds).
 *
 * @param time				Time in milliseconds.
 * @return					Number of seconds.
 */
stock float SimpleKZ_TimeIntToFloat(int time) {
	return time / 1000.0;
} 