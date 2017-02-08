/* 	Simple KZ Ranks API
	Author: DanZay
	
	Plugin Version: 0.7.1
	Plugin Website: https://github.com/danzayau/SimpleKZ	
*/

#if defined _simplekz_ranks_included_
#endinput
#endif
#define _simplekz_ranks_included_

#include <simplekz/core>


/*===============================  Enumerations  ===============================*/

enum RecordType {
	PRO_RECORD = 0, 
	MAP_RECORD, 
	MAP_AND_PRO_RECORD
}



/*===============================  Forwards  ===============================*/

/**
 * Called when the player sets a record.
 *
 * @param client			Client entity index.
 * @param map				The name of the map (without prefixes e.g. workshop/).
 * @param recordType		Type of record broken.
 * @param runTime			The run time of the record.
 * @noreturn
 */
forward void SimpleKZ_OnSetRecord(int client, const char[] map, RecordType recordType, float runTime); 