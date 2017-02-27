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
 * @param mapID 			MapID from SimpleKZ Core's "Maps" database table.
 * @param course			Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style				The movement style of the new record.
 * @param recordType		Type of record (see RecordType enumeration).
 * @param runTime			The run time of the record.
 * @noreturn
 */
forward void SimpleKZ_OnNewRecord(int client, int mapID, int course, MovementStyle style, RecordType recordType, float runTime);

/**
 * Called when the player beats their personal best time (not called when beating a map for the first time).
 *
 * @param client			Client entity index.
 * @param mapID 			MapID from SimpleKZ Core's "Maps" database table.
 * @param course			Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style				The movement style of the new PB.
 * @param timeType			The type of run (see TimeType enumeration).
 * @param firstTime			Whether or not this is the player's first completion.
 * @param runTime			The run time of the record.
 * @param improvement		The improvement over the old time (-1.0 if first time).
 * @param rank				The rank of the player's time.
 * @param maxRank			The number of players with times on the map.
 * @noreturn
 */
forward void SimpleKZ_OnNewPersonalBest(int client, int mapID, int course, MovementStyle style, TimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank);

/**
 * Called after SimpleKZ Ranks retrieves the current map's MapID from the "Maps" database table.
 *
 * @param playerID			MapID from SimpleKZ Core's "Maps" database table.
 * @noreturn
 */
forward void SimpleKZ_OnRetrieveCurrentMapID(int mapID);



/*===============================  Natives  ===============================*/

/**
 * Gets the current map's MapID as retrieved from SimpleKZ Core's "Players" database table. This is accurate after SimpleKZ_OnRetrieveCurrentMapID is called after the map is started.
 *
 * @return					MapID from SimpleKZ Ranks' "Maps" database table.
 */
native int SimpleKZ_GetCurrentMapID(int client); 