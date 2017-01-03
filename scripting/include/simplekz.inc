/* 	Simple KZ API Include File
	
	Author: DanZay
*/

/*=====  Double Include Prevention  ======*/
#if defined _simplekz_included_
#endinput
#endif
#define _simplekz_included_



/*=====  Forwards  ======*/

/**
 * Called when the player starts their timer.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerStarted(int clien);

/**
 * Called when the player ends their timer.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerEnded(int client);



/*=====  Natives  ======*/

/**
 * Gets whether or not the player's SimpleKZ timer is running.
 *
 * @param client    		Client entity index.
 * @return        			Whether or not the player's SimpleKZ timer is running.
 */
native bool SimpleKZ_GetTimerRunning(int client);

/**
 * Sets whether or not the player's SimpleKZ timer is running.
 *
 * @param client    		Client entity index.
 * @param running			Whether or not to set the player's SimpleKZ timer to be running.
 * @noreturn
 */
native void SimpleKZ_SetTimerRunning(int client, bool running); 