/*	dbqueries.sp

	Database queries.
*/

// PLAYEROPTIONS
char sql_createPlayerOptions[] = "";
char sql_insertPlayerOptions[] = "";
char sql_selectPlayerOptions[] = "";
char sql_updatePlayerOptions[] = "";

// PLAYERTIMES
char sql_createPlayerTimes[] = "";
char sql_insertPlayerTimes[] = "";
char sql_selectPlayerTimes[] = "";
char sql_updatePlayerTimes[] = "";

// ADMIN
char sql_resetMapTimes[] 			= "DELETE FROM playertimes WHERE mapname = '%s'";
char sql_resetPlayerTimes[] 		= "DELETE FROM playertimes WHERE steamid = '%s'";
char sql_resetPlayerTimesMap[]		= "DELETE FROM playertimes WHERE steamid = '%s' AND mapname = '%s'";
