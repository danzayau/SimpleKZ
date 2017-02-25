/* 	Simple KZ Ranks Include File
	Author: DanZay
	
	Plugin Version: 0.9.0
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_ranks_included_
#endinput
#endif
#define _simplekz_ranks_included_

#include <simplekz/core>


/*===============================  Enumerations  ===============================*/

enum RecordType {
	RecordType_Map = 0, 
	RecordType_Pro, 
	RecordType_MapAndPro
}



/*===============================  Forwards  ===============================*/

/**
 * Called when the player sets a record.
 *
 * @param client			Client entity index.
 * @param map				The name of the map (without prefixes e.g. workshop/).
 * @param style				The movement style of the record.
 * @param recordType		Type of record broken.
 * @param runTime			The run time of the record.
 * @noreturn
 */
forward void SimpleKZ_OnBeatMapRecord(int client, const char[] map, MovementStyle style, RecordType recordType, float runTime);

/**
 * Called when the player beats the map for the first time.
 *
 * @param client			Client entity index.
 * @param map				The name of the map (without prefixes e.g. workshop/).
 * @param style				The movement style of their new PB.
 * @param runType			The type of run.
 * @param runTime			The run time.
 * @param rank				The rank of the player's time.
 * @param maxRank			The number of players with times on the map.
 * @noreturn
 */
forward void SimpleKZ_OnBeatMapFirstTime(int client, const char[] map, MovementStyle style, RunType runType, float runTime, int rank, int maxRank);

/**
 * Called when the player beats their personal best time (not called when beating a map for the first time).
 *
 * @param client			Client entity index.
 * @param map				The name of the map (without prefixes e.g. workshop/).
 * @param style				The movement style of their new PB.
 * @param runType			The type of run.
 * @param runTime			The run time of the record.
 * @param improvement		The improvement over the old time.
 * @param rank				The rank of the player's time.
 * @param maxRank			The number of players with times on the map.
 * @noreturn
 */
forward void SimpleKZ_OnImproveTime(int client, const char[] map, MovementStyle style, RunType runType, float runTime, float improvement, int rank, int maxRank); 