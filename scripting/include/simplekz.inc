/* 	Simple KZ API Include File
	
	Author: DanZay
*/


/*	Double-include prevention	*/
#if defined _movementtweaker_included_
#endinput
#endif
#define _movementtweaker_included_

// Forwards

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