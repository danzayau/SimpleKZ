/* 	
	SimpleKZ Local Ranks Include File
	
	Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_localranks_included_
#endinput
#endif
#define _simplekz_localranks_included_



/*===============================  Enumerations  ===============================*/

enum KZRecordType {
	KZRecordType_Nub = 0, 
	KZRecordType_Pro, 
	KZRecordType_NubAndPro
}



/*===============================  Forwards  ===============================*/

/**
 * Called when a player sets a new local record.
 * Not called for theoretical times.
 *
 * @param client			Client index (-1 if client is no longer present).
 * @param steamID			SteamID32 of the player.
 * @param mapID 			MapID from the "Maps" table.
 * @param course    		Course number e.g. 0=main, 1='bonus1' etc.
 * @param style				Player's movement style.
 * @param recordType		Type of record.
 * @param runTime			Run time of the record.
 * @noreturn
 */
forward void SKZ_DB_OnNewRecord(int client, int steamID, int mapID, int course, KZStyle style, KZRecordType recordType, float runTime);

/**
 * Called when a player sets a new local personal best.
 * Not called for theoretical times.
 *
 * @param client			Client index (-1 if client is no longer present).
 * @param steamID			SteamID32 of the player.
 * @param mapID 			MapID from the "Maps" database table.
 * @param course    		Course number e.g. 0=main, 1='bonus1' etc.
 * @param style				Player's movement style.
 * @param timeType			Type of time.
 * @param firstTime			Whether this is player's first time on this course.
 * @param runTime			Run time of the record in seconds.
 * @param improvement		Improvement over old time in seconds (-1.0 if first time).
 * @param rank				Rank of the player's time.
 * @param maxRank			Total number of players with times.
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