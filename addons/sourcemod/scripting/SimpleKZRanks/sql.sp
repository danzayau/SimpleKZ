/*	sql.sp
	
	SQL statement templates for database.
*/


/*===============================  Maps Table  ===============================*/

char sql_maps_create[] = 
"CREATE TABLE IF NOT EXISTS Maps ("
..."Map VARCHAR(32) NOT NULL, "
..."InRankedPool TINYINT(1) NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Maps PRIMARY KEY (Map));";

char sqlite_maps_insert[] = 
"INSERT OR IGNORE INTO Maps "
..."(InRankedPool, Map) "
..."VALUES(%d, '%s');";

char sqlite_maps_update[] = 
"UPDATE OR IGNORE Maps "
..."SET InRankedPool=%d "
..."WHERE Map='%s';";

char mysql_maps_insert[] = 
"INSERT IGNORE INTO Maps "
..."(InRankedPool, Map) "
..."VALUES(%d, '%s');";

char mysql_maps_upsert[] = 
"INSERT INTO Maps "
..."(InRankedPool, Map) "
..."VALUES(%d, '%s') "
..."ON DUPLICATE KEY UPDATE "
..."InRankedPool=VALUES(InRankedPool);";

char sql_maps_reset_mappool[] = 
"UPDATE Maps "
..."SET InRankedPool=0;";

char sql_maps_select_like[] = 
"SELECT Map "
..."FROM Maps "
..."WHERE Map LIKE '%%%s%%' "
..."ORDER BY (Map='%s') DESC, LENGTH(Map) "
..."LIMIT 1;";



/*===============================  Times Table  ===============================*/

char sqlite_times_create[] = 
"CREATE TABLE IF NOT EXISTS Times ("
..."TimeID INTEGER, "
..."SteamID VARCHAR(24) NOT NULL, "
..."Map VARCHAR(32) NOT NULL, "
..."RunTime FLOAT UNSIGNED NOT NULL, "
..."Teleports SMALLINT UNSIGNED NOT NULL, "
..."TheoreticalRunTime FLOAT UNSIGNED NOT NULL, "
..."Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Times PRIMARY KEY (TimeID), "
..."CONSTRAINT FK_Times_SteamID FOREIGN KEY (SteamID) REFERENCES Players (SteamID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_Times_Map FOREIGN KEY (Map) REFERENCES Maps (Map) ON UPDATE CASCADE ON DELETE CASCADE);";

char mysql_times_create[] = 
"CREATE TABLE IF NOT EXISTS Times ("
..."TimeID INTEGER UNSIGNED NOT NULL AUTO_INCREMENT, "
..."SteamID VARCHAR(24) NOT NULL, "
..."Map VARCHAR(32) NOT NULL, "
..."RunTime FLOAT UNSIGNED NOT NULL, "
..."Teleports SMALLINT UNSIGNED NOT NULL, "
..."TheoreticalRunTime FLOAT UNSIGNED NOT NULL, "
..."Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."INDEX IX_MapSteamID (Map, SteamID), "
..."CONSTRAINT PK_Times PRIMARY KEY (TimeID), "
..."CONSTRAINT FK_Times_SteamID FOREIGN KEY (SteamID) REFERENCES Players (SteamID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_Times_Map FOREIGN KEY (Map) REFERENCES Maps (Map) ON UPDATE CASCADE ON DELETE CASCADE);";

char sqlite_times_createindex_mapsteamid[] = 
"CREATE INDEX IF NOT EXISTS IX_MapSteamID "
..."ON Times (Map, SteamID);";

char sql_times_insert[] = 
"INSERT "
..."INTO Times "
..."(SteamID, Map, RunTime, Teleports, TheoreticalRunTime) "
..."VALUES('%s', '%s', %f, %d, %f);";



/*===============================  General  ===============================*/

char sql_getpb[] = 
"SELECT RunTime, Teleports, TheoreticalRunTime "
..."FROM Times "
..."WHERE Map='%s' AND SteamID='%s' "
..."ORDER BY RunTime "
..."LIMIT %d;";

char sql_getpbpro[] = 
"SELECT RunTime "
..."FROM Times "
..."WHERE Map='%s' AND SteamID='%s' AND Teleports=0 "
..."ORDER BY RunTime "
..."LIMIT %d;";

char sql_getmaptop[] = 
"SELECT Players.Alias, Times.RunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.SteamID=Times.SteamID "
..."WHERE Times.RunTime IN "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE Map='%s' "
..."GROUP BY SteamID) "
..."AND Map='%s' "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoppro[] = 
"SELECT Players.Alias, Times.RunTime "
..."FROM Times "
..."INNER JOIN Players ON Players.SteamID=Times.SteamID "
..."WHERE Times.RunTime IN "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE Map='%s' AND Teleports=0 "
..."GROUP BY SteamID) "
..."AND Map='%s' "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoptheoretical[] = 
"SELECT Players.Alias, Times.TheoreticalRunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.SteamID=Times.SteamID "
..."WHERE Times.TheoreticalRunTime IN "
..."(SELECT MIN(TheoreticalRunTime) "
..."FROM Times "
..."WHERE Map='%s' "
..."GROUP BY SteamID) "
..."AND Map='%s' "
..."ORDER BY Times.TheoreticalRunTime "
..."LIMIT %d;";

char sql_getmaprank[] = 
"SELECT COUNT(*) "
..."FROM "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE RunTime <= "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE Map='%s' AND SteamID='%s') "
..."AND Map='%s' "
..."GROUP BY SteamID) AS FasterTimes;";

char sql_getmaprankpro[] = 
"SELECT COUNT(*) "
..."FROM "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE RunTime <= "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE Map='%s' AND SteamID='%s' AND Teleports=0) "
..."AND Map='%s' AND Teleports=0 "
..."GROUP BY SteamID) AS FasterTimes;";

char sql_getlowestmaprank[] = 
"SELECT COUNT(DISTINCT SteamID) "
..."FROM Times "
..."WHERE Map='%s';";

char sql_getlowestmaprankpro[] = 
"SELECT COUNT(DISTINCT SteamID) "
..."FROM Times "
..."WHERE Map='%s' AND Teleports=0;";

char sql_getcounttotalmaps[] = 
"SELECT COUNT(*) "
..."FROM Maps "
..."WHERE InRankedPool='1';";

char sql_getcountmapscompleted[] = 
"SELECT COUNT(DISTINCT Times.Map) "
..."FROM Times "
..."INNER JOIN Maps ON Maps.Map=Times.Map "
..."WHERE Times.SteamID='%s' AND Maps.InRankedPool=1;";

char sql_getcountmapscompletedpro[] = 
"SELECT COUNT(DISTINCT Times.Map) "
..."FROM Times "
..."INNER JOIN Maps ON Maps.Map=Times.Map "
..."WHERE Times.SteamID='%s' AND Maps.InRankedPool=1 AND Times.Teleports=0;";

char sql_gettopplayers[] = 
"SELECT Players.Alias, COUNT(*) AS RecordCount "
..."FROM "
..."(SELECT Times.SteamID "
..."FROM Times "
..."INNER JOIN "
..."(SELECT Times.Map, MIN(Times.RunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN Maps ON Maps.Map=Times.Map "
..."WHERE Maps.InRankedPool=1 "
..."GROUP BY Times.Map) Records "
..."ON Times.Map=Records.Map AND Times.RunTime=Records.RecordTime) RecordHolders "
..."INNER JOIN Players ON Players.SteamID=RecordHolders.SteamID "
..."GROUP BY Players.Alias "
..."ORDER BY RecordCount DESC "
..."LIMIT 20;";

char sql_gettopplayerspro[] = 
"SELECT Players.Alias, COUNT(*) AS RecordCount "
..."FROM "
..."(SELECT Times.SteamID "
..."FROM Times "
..."INNER JOIN "
..."(SELECT Times.Map, MIN(Times.RunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN Maps ON Maps.Map=Times.Map "
..."WHERE Maps.InRankedPool=1 AND Teleports=0 "
..."GROUP BY Times.Map) Records "
..."ON Times.Map=Records.Map AND Times.RunTime=Records.RecordTime) RecordHolders "
..."INNER JOIN Players ON Players.SteamID=RecordHolders.SteamID "
..."GROUP BY Players.Alias "
..."ORDER BY RecordCount DESC "
..."LIMIT 20;"; 