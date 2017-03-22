/*	sql.sp
	
	SQL statement templates for database.
*/


/*===============================  Maps Table  ===============================*/

char sqlite_maps_alter1[] = 
"ALTER TABLE Maps "
..."ADD InRankedPool INTEGER NOT NULL DEFAULT '0';";

char mysql_maps_alter1[] = 
"ALTER TABLE Maps "
..."ADD InRankedPool INTEGER NOT NULL DEFAULT '0';";

char sqlite_maps_insertranked[] = 
"INSERT OR IGNORE INTO Maps "
..."(InRankedPool, Name) "
..."VALUES(%d, '%s');";

char sqlite_maps_updateranked[] = 
"UPDATE OR IGNORE Maps "
..."SET InRankedPool=%d "
..."WHERE Name='%s';";

char mysql_maps_upsertranked[] = 
"INSERT INTO Maps (InRankedPool, Name) "
..."VALUES (%d, '%s') "
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

// There's probably a better way to get map top but this seems to work...
char sql_getmaptop[] = 
"SELECT Players.Alias, Times.RunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT MIN(RunTime) AS PBTime, MapID, Course, Style, PlayerID "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d "
..."GROUP BY MapID, Course, Style, PlayerID) PBs "
..."ON PBs.PBTime=Times.RunTime AND PBs.MapID=Times.MapID AND PBs.Course=Times.Course AND PBs.Style=Times.Style AND PBs.PlayerID=Times.PlayerID "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoppro[] = 
"SELECT Players.Alias, Times.RunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT MIN(RunTime) AS PBTime, MapID, Course, Style, PlayerID "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d AND Teleports=0 "
..."GROUP BY MapID, Course, Style, PlayerID) PBs "
..."ON PBs.PBTime=Times.RunTime AND PBs.MapID=Times.MapID AND PBs.Course=Times.Course AND PBs.Style=Times.Style AND PBs.PlayerID=Times.PlayerID "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoptheoretical[] = 
"SELECT Players.Alias, Times.TheoreticalRunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT MIN(TheoreticalRunTime) AS PBTime, MapID, Course, Style, PlayerID "
..."FROM Times "
..."WHERE MapID=%d AND Course=%d AND Style=%d "
..."GROUP BY MapID, Course, Style, PlayerID) PBs "
..."ON PBs.PBTime=Times.TheoreticalRunTime AND PBs.MapID=Times.MapID AND PBs.Course=Times.Course AND PBs.Style=Times.Style AND PBs.PlayerID=Times.PlayerID "
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