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
forward void SimpleKZ_OnTimerStarted(int client);

/**
 * Called when the player ends their timer.
 *
 * @param client			Client entity index.
 * @noreturn
 */
forward void SimpleKZ_OnTimerEnded(int client);



/*=====  Natives  ======*/

/**
 * Starts the players timer.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_StartTimer(int client);

/**
 * Ends the players timer.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_EndTimer(int client);

/**
 * Forces the players timer to stop without calling SimpleKZ_OnTimerEnded. Intended for run invalidation.
 *
 * @param client    		Client entity index.
 * @noreturn
 */
native void SimpleKZ_ForceStopTimer(int client); 