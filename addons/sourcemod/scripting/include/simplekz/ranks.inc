/* 	Simple KZ Ranks API
	Author: DanZay
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
 * Called when the player breaks a record.
 *
 * @param client			Client entity index.
 * @param recordType		Type of record broken.
 * @noreturn
 */
forward void SimpleKZ_OnGetRecord(int client, RecordType recordType); 