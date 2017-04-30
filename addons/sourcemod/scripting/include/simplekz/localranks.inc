/* 	
	Simple KZ Local Ranks Include File
	
	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_localranks_included_
#endinput
#endif
#define _simplekz_localranks_included_



/*===============================  Enumerations  ===============================*/

enum KZRecordType {
	KZRecordType_Map = 0, 
	KZRecordType_Pro, 
	KZRecordType_MapAndPro
}



/*===============================  Forwards  ===============================*/

/**
 * Called when the player sets a new local record.
 *
 * @param client				Client entity index (-1 if client is no longer present).
 * @param steamID				SteamID32 of the player.
 * @param mapID 				MapID from the "Maps" database table.
 * @param course				Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style					The movement style of the new record.
 * @param recordType			Type of record (see KZRecordType enumeration).
 * @param runTime				The run time of the record.
 * @noreturn
 */
forward void SKZ_DB_OnNewRecord(int client, int steamID, int mapID, int course, KZStyle style, KZRecordType recordType, float runTime);

/**
 * Called when the player sets a new local personal best (not called for theoretical times).
 *
 * @param client				Client entity index (-1 if client is no longer present).
 * @param steamID				SteamID32 of the player.
 * @param mapID 				MapID from the "Maps" database table.
 * @param course				Which part of the map (main=0, 'bonus1'=1, 'bonus2'=2 etc.).
 * @param style					The movement style of the new PB.
 * @param timeType				The type of run (see TimeType enumeration).
 * @param firstTime				Whether or not this is the player's first completion.
 * @param runTime				The run time of the record.
 * @param improvement			The improvement over the old time (-1.0 if first time).
 * @param rank					The rank of the player's time.
 * @param maxRank				The number of players with times on the map.
 * @noreturn
 */
forward void SKZ_DB_OnNewPersonalBest(int client, int steamID, int mapID, int course, KZStyle style, KZTimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank);



/*===============================  Dependency  ===============================*/

public SharedPlugin __pl_simplekz_localranks = 
{
	name = "simplekz-localranks", 
	file = "simplekz-localranks.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
}; 