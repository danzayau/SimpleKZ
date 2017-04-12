/*
	Database
	
	Database interaction.
*/

#include "simplekz-localdb/database/sql.sp"
#include "simplekz-localdb/database/create_tables.sp"
#include "simplekz-localdb/database/load_options.sp"
#include "simplekz-localdb/database/save_options.sp"
#include "simplekz-localdb/database/save_time.sp"
#include "simplekz-localdb/database/setup_client.sp"
#include "simplekz-localdb/database/setup_database.sp"
#include "simplekz-localdb/database/setup_map.sp"
#include "simplekz-localdb/database/setup_map_courses.sp"

/* Error report callback for failed transactions */
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	SetFailState("%T", "Database Transaction Error", LANG_SERVER, error);
} 