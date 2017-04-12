/*	
	SQL
	
	SQL statement templates for database.
*/


/*===============================  Maps Table  ===============================*/

char sqlite_maps_alter1[] = 
"ALTER TABLE Maps "
..."ADD InRankedPool INTEGER NOT NULL DEFAULT '0';";

char mysql_maps_alter1[] = 
"ALTER TABLE Maps "
..."ADD InRankedPool TINYINT NOT NULL DEFAULT '0';";

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

char sql_maps_searchbyname[] = 
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

char sql_players_searchbyalias[] = 
"SELECT PlayerID, Alias "
..."FROM Players "
..."WHERE LOWER(Alias) LIKE '%%%s%%' "
..."ORDER BY (LOWER(Alias)='%s') DESC, LastPlayed DESC "
..."LIMIT 1;";



/*===============================  Map Courses  ===============================*/

char sql_mapcourses_findid[] = 
"SELECT MapCourseID "
..."FROM MapCourses "
..."WHERE MapID=%d AND Course=%d;";



/*===============================  General  ===============================*/

char sql_getpb[] = 
"SELECT Times.RunTime, Times.Teleports, Times.TheoreticalRunTime "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE Times.PlayerID=%d AND MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getpbpro[] = 
"SELECT Times.RunTime "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE Times.PlayerID=%d AND MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d AND Times.Teleports=0 "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptop[] = 
"SELECT Players.Alias, Times.RunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT MIN(Times.RunTime) AS PBTime, Times.MapCourseID, Times.Style, Times.PlayerID "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d "
..."GROUP BY MapCourses.MapID, MapCourses.Course, Times.Style, Times.PlayerID) PBs "
..."ON PBs.PBTime=Times.RunTime AND PBs.MapCourseID=Times.MapCourseID AND PBs.Style=Times.Style AND PBs.PlayerID=Times.PlayerID "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoppro[] = 
"SELECT Players.Alias, Times.RunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT MIN(Times.RunTime) AS PBTime, Times.MapCourseID, Times.Style, Times.PlayerID "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d AND Times.Teleports=0 "
..."GROUP BY MapCourses.MapID, MapCourses.Course, Times.Style, Times.PlayerID) PBs "
..."ON PBs.PBTime=Times.RunTime AND PBs.MapCourseID=Times.MapCourseID AND PBs.Style=Times.Style AND PBs.PlayerID=Times.PlayerID "
..."ORDER BY Times.RunTime "
..."LIMIT %d;";

char sql_getmaptoptheoretical[] = 
"SELECT Players.Alias, Times.TheoreticalRunTime, Times.Teleports "
..."FROM Times "
..."INNER JOIN Players ON Players.PlayerID=Times.PlayerID "
..."INNER JOIN "
..."(SELECT MIN(Times.TheoreticalRunTime) AS PBTime, Times.MapCourseID, Times.Style, Times.PlayerID "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d "
..."GROUP BY MapCourses.MapID, MapCourses.Course, Times.Style, Times.PlayerID) PBs "
..."ON PBs.PBTime=Times.TheoreticalRunTime AND PBs.MapCourseID=Times.MapCourseID AND PBs.Style=Times.Style AND PBs.PlayerID=Times.PlayerID "
..."ORDER BY Times.TheoreticalRunTime "
..."LIMIT %d;";

char sql_getmaprank[] = 
"SELECT COUNT(*) "
..."FROM "
..."(SELECT MIN(Times.RunTime) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE RunTime <= "
..."(SELECT MIN(Times.RunTime) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE Times.PlayerID=%d AND MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d) "
..."AND MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d "
..."GROUP BY PlayerID) AS FasterTimes;";

char sql_getmaprankpro[] = 
"SELECT COUNT(*) "
..."FROM "
..."(SELECT MIN(Times.RunTime) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE RunTime <= "
..."(SELECT MIN(Times.RunTime) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE Times.PlayerID=%d AND MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d AND Times.Teleports=0) "
..."AND MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d AND Times.Teleports=0 "
..."GROUP BY PlayerID) AS FasterTimes;";

char sql_getlowestmaprank[] = 
"SELECT COUNT(DISTINCT Times.PlayerID) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d;";

char sql_getlowestmaprankpro[] = 
"SELECT COUNT(DISTINCT Times.PlayerID) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."WHERE MapCourses.MapID=%d AND MapCourses.Course=%d AND Times.Style=%d AND Times.Teleports=0;";

char sql_getcount_maincourses[] = 
"SELECT COUNT(*) "
..."FROM MapCourses "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course=0;";

char sql_getcount_maincoursescompleted[] = 
"SELECT COUNT(DISTINCT Times.MapCourseID) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course=0 AND Times.PlayerID=%d AND Times.Style=%d;";

char sql_getcount_maincoursescompletedpro[] = 
"SELECT COUNT(DISTINCT Times.MapCourseID) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course=0 AND Times.PlayerID=%d AND Times.Style=%d AND Times.Teleports=0;";

char sql_getcount_bonuses[] = 
"SELECT COUNT(*) "
..."FROM MapCourses "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course>0;";

char sql_getcount_bonusescompleted[] = 
"SELECT COUNT(DISTINCT Times.MapCourseID) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course>0 AND Times.PlayerID=%d AND Times.Style=%d;";

char sql_getcount_bonusescompletedpro[] = 
"SELECT COUNT(DISTINCT Times.MapCourseID) "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course>0 AND Times.PlayerID=%d AND Times.Style=%d AND Times.Teleports=0;";

char sql_gettopplayers_map[] = 
"SELECT Players.Alias, COUNT(*) AS RecordCount "
..."FROM "
..."(SELECT Times.PlayerID "
..."FROM Times "
..."INNER JOIN "
..."(SELECT Times.MapCourseID, MIN(Times.RunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course=0 AND Times.Style=%d " // Doesn't include bonuses.
..."GROUP BY Times.MapCourseID) Records "
..."ON Times.MapCourseID=Records.MapCourseID AND Times.RunTime=Records.RecordTime) RecordHolders "
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
..."(SELECT Times.MapCourseID, MIN(Times.RunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course=0 AND Times.Style=%d AND Times.Teleports=0 " // Doesn't include bonuses.
..."GROUP BY Times.MapCourseID) Records "
..."ON Times.MapCourseID=Records.MapCourseID AND Times.RunTime=Records.RecordTime) RecordHolders "
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
..."(SELECT Times.MapCourseID, MIN(Times.TheoreticalRunTime) AS RecordTime "
..."FROM Times "
..."INNER JOIN MapCourses ON MapCourses.MapCourseID=Times.MapCourseID "
..."INNER JOIN Maps ON Maps.MapID=MapCourses.MapID "
..."WHERE Maps.InRankedPool=1 AND MapCourses.Course=0 AND Times.Style=%d " // Doesn't include bonuses.
..."GROUP BY Times.MapCourseID) Records "
..."ON Times.MapCourseID=Records.MapCourseID AND Times.TheoreticalRunTime=Records.RecordTime) RecordHolders "
..."INNER JOIN Players ON Players.PlayerID=RecordHolders.PlayerID "
..."GROUP BY Players.Alias "
..."ORDER BY RecordCount DESC "
..."LIMIT 20;"; 