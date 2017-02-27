/*	sql.sp
	
	SQL statement templates for database.
*/


/*===============================  Maps Table  ===============================*/

char sqlite_maps_create[] = 
"CREATE TABLE IF NOT EXISTS Maps ("
..."MapID INTEGER, "
..."Name VARCHAR(32) NOT NULL UNIQUE, "
..."InRankedPool TINYINT(1) NOT NULL DEFAULT '0', "
..."LastPlayed TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Maps PRIMARY KEY (MapID));";

char mysql_maps_create[] = 
"CREATE TABLE IF NOT EXISTS Maps ("
..."MapID INTEGER UNSIGNED NOT NULL AUTO_INCREMENT, "
..."Name VARCHAR(32) NOT NULL UNIQUE, "
..."InRankedPool TINYINT(1) NOT NULL DEFAULT '0', "
..."LastPlayed TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Maps PRIMARY KEY (MapID));";

char sqlite_maps_insert[] = 
"INSERT OR IGNORE INTO Maps "
..."(Name) "
..."VALUES('%s');";

char sqlite_maps_update[] = 
"UPDATE OR IGNORE Maps "
..."SET LastPlayed=CURRENT_TIMESTAMP "
..."WHERE Name='%s';";

char mysql_maps_upsert[] = 
"INSERT INTO Maps "
..."(Name) "
..."VALUES('%s') "
..."ON DUPLICATE KEY UPDATE "
..."LastPlayed=CURRENT_TIMESTAMP;";

char sqlite_maps_insertranked[] = 
"INSERT OR IGNORE INTO Maps "
..."(InRankedPool, Name) "
..."VALUES(%d, '%s');";

char sqlite_maps_updateranked[] = 
"UPDATE OR IGNORE Maps "
..."SET InRankedPool=%d "
..."WHERE Name='%s';";

char mysql_maps_upsertranked[] = 
"INSERT INTO Maps "
..."(InRankedPool, Name) "
..."VALUES(%d, '%s') "
..."ON DUPLICATE KEY UPDATE "
..."InRankedPool=VALUES(InRankedPool);";

char sql_maps_reset_mappool[] = 
"UPDATE Maps "
..."SET InRankedPool=0;";

char sql_maps_getname[] = 
"SELECT Name "
..."FROM Maps "
..."WHERE MapID=%d;";

char sql_maps_findid[] = 
"SELECT MapID, Name "
..."FROM Maps "
..."WHERE Name LIKE '%%%s%%' "
..."ORDER BY (Name='%s') DESC, LENGTH(Name) "
..."LIMIT 1;";



/*===============================  Times Table  ===============================*/

char sqlite_times_create[] = 
"CREATE TABLE IF NOT EXISTS Times ("
..."TimeID INTEGER, "
..."PlayerID INTEGER, "
..."MapID INTEGER, "
..."Course INTEGER UNSIGNED NOT NULL, "
..."Style INTEGER UNSIGNED NOT NULL, "
..."RunTime FLOAT UNSIGNED NOT NULL, "
..."Teleports SMALLINT UNSIGNED NOT NULL, "
..."TheoreticalRunTime FLOAT UNSIGNED NOT NULL, "
..."Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Times PRIMARY KEY (TimeID), "
..."CONSTRAINT FK_Times_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_Times_MapID FOREIGN KEY (MapID) REFERENCES Maps (MapID) ON UPDATE CASCADE ON DELETE CASCADE);";

char sqlite_times_create_index1[] = 
"CREATE INDEX IF NOT EXISTS IX_Times_PlayerID "
..."ON Times (PlayerID);";

char sqlite_times_create_index2[] = 
"CREATE INDEX IF NOT EXISTS IX_Times_MapID "
..."ON Times (MapID);";

char sqlite_times_create_index3[] = 
"CREATE INDEX IF NOT EXISTS IX_Times_Teleports "
..."ON Times (Teleports);";

char sqlite_times_create_index4[] = 
"CREATE INDEX IF NOT EXISTS IX_Times_Style_Course_MapID "
..."ON Times (Style, Course, MapID);";

char mysql_times_create[] = 
"CREATE TABLE IF NOT EXISTS Times ("
..."TimeID INTEGER UNSIGNED NOT NULL AUTO_INCREMENT, "
..."PlayerID INTEGER UNSIGNED NOT NULL, "
..."MapID INTEGER UNSIGNED NOT NULL, "
..."Course TINYINT UNSIGNED NOT NULL, "
..."Style TINYINT UNSIGNED NOT NULL, "
..."RunTime FLOAT UNSIGNED NOT NULL, "
..."Teleports SMALLINT UNSIGNED NOT NULL, "
..."TheoreticalRunTime FLOAT UNSIGNED NOT NULL, "
..."Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."INDEX IX_Times_PlayerID (PlayerID), "
..."INDEX IX_Times_MapID (MapID), "
..."INDEX IX_Times_Teleports (Teleports), "
..."INDEX IX_Times_Style_Course_MapID (Style, Course, MapID), "
..."CONSTRAINT PK_Times PRIMARY KEY (TimeID), "
..."CONSTRAINT FK_Times_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_Times_MapID FOREIGN KEY (MapID) REFERENCES Maps (MapID) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_times_insert[] = 
"INSERT "
..."INTO Times "
..."(PlayerID, MapID, Course, Style, RunTime, Teleports, TheoreticalRunTime) "
..."VALUES(%d, %d, %d, %d, %f, %d, %f);";



/*===============================  Players Table  ===============================*/

char sql_players_getalias[] = 
"SELECT Alias "
..."FROM Players "
..."WHERE PlayerID=%d;";

char sql_players_findid[] = 
"SELECT PlayerID, Alias "
..."FROM Players "
..."WHERE LOWER(Alias) LIKE '%%%s%%' "
..."ORDER BY (LOWER(Alias)='%s') DESC, LastSeen DESC "
..."LIMIT 1;";



/*===============================  General  ===============================*/

char sql_getpb[] = 
"SELECT RunTime, Teleports, TheoreticalRunTime "
..."FROM Times "
..."WHERE PlayerID=%d AND MapID=%d AND Course=%d AND Style=%d "
..."ORDER BY RunTime "
..."LIMIT %d;";

char sql_getpbpro[] = 
"SELECT RunTime "
..."FROM Times "
..."WHERE PlayerID=%d AND MapID=%d AND Course=%d AND Style=%d AND Teleports=0 "
..."ORDER BY RunTime "
..."LIMIT %d;";

char sql_getmaptop[] = 
"SELECT Players.Alias, Times.RunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT TimeID, MIN(RunTime) "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d "
..."GROUP BY TimeID, PlayerID) TopTimes "
..."ON TopTimes.TimeID=Times.TimeID "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoppro[] = 
"SELECT Players.Alias, Times.RunTime "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT TimeID, MIN(RunTime) "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d AND Teleports=0 "
..."GROUP BY TimeID, PlayerID) TopTimes "
..."ON TopTimes.TimeID=Times.TimeID "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoptheoretical[] = 
"SELECT Players.Alias, Times.TheoreticalRunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT TimeID, MIN(TheoreticalRunTime) "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d "
..."GROUP BY TimeID, PlayerID) TopTimes "
..."ON TopTimes.TimeID=Times.TimeID "
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
..."WHERE PlayerID=%d AND MapID=%d AND Course=%d AND Style=%d) "
..."AND MapID=%d AND Course=%d AND Style=%d "
..."GROUP BY PlayerID) AS FasterTimes;";

char sql_getmaprankpro[] = 
"SELECT COUNT(*) "
..."FROM "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE RunTime <= "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE PlayerID=%d AND MapID=%d AND Course=%d AND Style=%d AND Teleports=0) "
..."AND MapID=%d AND Course=%d AND Style=%d AND Teleports=0 "
..."GROUP BY PlayerID) AS FasterTimes;";

char sql_getlowestmaprank[] = 
"SELECT COUNT(DISTINCT PlayerID) "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d;";

char sql_getlowestmaprankpro[] = 
"SELECT COUNT(DISTINCT PlayerID) "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d AND Teleports=0;";

char sql_getcounttotalmaps[] = 
"SELECT COUNT(*) "
..."FROM Maps "
..."WHERE InRankedPool=1;";

char sql_getcountmapscompleted[] = 
"SELECT COUNT(DISTINCT Times.MapID) "
..."FROM Times "
..."INNER JOIN Maps ON Maps.MapID=Times.MapID "
..."WHERE Maps.InRankedPool=1 AND Times.PlayerID=%d AND Times.Course=0 AND Times.Style=%d;";

char sql_getcountmapscompletedpro[] = 
"SELECT COUNT(DISTINCT Times.MapID) "
..."FROM Times "
..."INNER JOIN Maps ON Maps.MapID=Times.MapID "
..."WHERE Maps.InRankedPool=1 AND Times.PlayerID=%d AND Times.Course=0 AND Times.Style=%d AND Times.Teleports=0;";

char sql_gettopplayers_map[] = 
"SELECT Players.Alias, COUNT(*) AS RecordCount "
..."FROM "
..."(SELECT Times.PlayerID "
..."FROM Times "
..."INNER JOIN "
..."(SELECT Times.MapID, MIN(Times.RunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN Maps ON Maps.MapID=Times.MapID "
..."WHERE Maps.InRankedPool=1 AND Times.Course=0 AND Times.Style=%d "
..."GROUP BY Times.MapID) Records "
..."ON Times.MapID=Records.MapID AND Times.RunTime=Records.RecordTime) RecordHolders "
..."INNER JOIN Players ON Players.PlayerID=RecordHolders.PlayerID "
..."GROUP BY Players.Alias "
..."ORDER BY RecordCount DESC "
..."LIMIT 20;";

char sql_gettopplayers_pro[] = 
"SELECT Players.Alias, COUNT(*) AS RecordCount "
..."FROM "
..."(SELECT Times.PlayerID "
..."FROM Times "
..."INNER JOIN "
..."(SELECT Times.MapID, MIN(Times.RunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN Maps ON Maps.MapID=Times.MapID "
..."WHERE Maps.InRankedPool=1 AND Times.Course=0 AND Times.Style=%d AND Times.Teleports=0 "
..."GROUP BY Times.MapID) Records "
..."ON Times.MapID=Records.MapID AND Times.RunTime=Records.RecordTime) RecordHolders "
..."INNER JOIN Players ON Players.PlayerID=RecordHolders.PlayerID "
..."GROUP BY Players.Alias "
..."ORDER BY RecordCount DESC "
..."LIMIT 20;";

char sql_gettopplayers_theoretical[] = 
"SELECT Players.Alias, COUNT(*) AS RecordCount "
..."FROM "
..."(SELECT Times.PlayerID "
..."FROM Times "
..."INNER JOIN "
..."(SELECT Times.MapID, MIN(Times.TheoreticalRunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN Maps ON Maps.MapID=Times.MapID "
..."WHERE Maps.InRankedPool=1 AND Times.Course=0 AND Times.Style=%d "
..."GROUP BY Times.MapID) Records "
..."ON Times.MapID=Records.MapID AND Times.TheoreticalRunTime=Records.RecordTime) RecordHolders "
..."INNER JOIN Players ON Players.PlayerID=RecordHolders.PlayerID "
..."GROUP BY Players.Alias "
..."ORDER BY RecordCount DESC "
..."LIMIT 20;"; 