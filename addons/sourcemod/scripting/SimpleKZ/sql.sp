/*	sql.sp
	
	SQL statements for database.
*/


// Players
char sql_players_create[] = 
"CREATE TABLE IF NOT EXISTS Players ("
..."SteamID VARCHAR(24) NOT NULL, "
..."Alias VARCHAR(32) NOT NULL, "
..."Country VARCHAR(45) NOT NULL, "
..."FirstSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."LastSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Player PRIMARY KEY (SteamID));";

char sql_players_insert[] = 
"INSERT OR IGNORE INTO Players "
..."(Alias, Country, SteamID) "
..."VALUES('%s', '%s', '%s');";

char sql_players_update[] = 
"UPDATE OR IGNORE Players "
..."SET Alias='%s', Country='%s', LastSeen=CURRENT_TIMESTAMP "
..."WHERE SteamID='%s';";

char mysql_players_saveinfo[] = 
"INSERT INTO Players "
..."(SteamID, Alias, Country) "
..."VALUES('%s', '%s', '%s') "
..."ON DUPLICATE KEY UPDATE "
..."SteamID=VALUES(SteamID), Alias=VALUES(Alias), Country=VALUES(Country);";


// Preferences
char sql_preferences_create[] = 
"CREATE TABLE IF NOT EXISTS Preferences ("
..."SteamID VARCHAR(24) NOT NULL, "
..."ShowingTeleportMenu TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingInfoPanel TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingKeys TINYINT(1) NOT NULL DEFAULT '0', "
..."ShowingPlayers TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingWeapon TINYINT(1) NOT NULL DEFAULT '1', "
..."Pistol TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Preferences PRIMARY KEY (SteamID), "
..."CONSTRAINT FK_Preferences_SteamID FOREIGN KEY (SteamID) REFERENCES Players (SteamID) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_preferences_insert[] = 
"INSERT "
..."INTO Preferences "
..."(SteamID) "
..."VALUES('%s');";

char sql_preferences_update[] = 
"UPDATE Preferences "
..."SET ShowingTeleportMenu=%d, ShowingInfoPanel=%d, ShowingKeys=%d, ShowingPlayers=%d, ShowingWeapon=%d, Pistol=%d "
..."WHERE SteamID='%s';";

char sql_preferences_get[] = 
"SELECT ShowingTeleportMenu, ShowingInfoPanel, ShowingKeys, ShowingPlayers, ShowingWeapon, Pistol "
..."FROM Preferences "
..."WHERE SteamID='%s';";


// Maps
char sql_maps_create[] = 
"CREATE TABLE IF NOT EXISTS Maps ("
..."Map VARCHAR(32) NOT NULL, "
..."Tier TINYINT UNSIGNED, "
..."InMapPool TINYINT(1) NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Maps PRIMARY KEY (Map));";

char sqlite_maps_insert[] = 
"INSERT OR IGNORE "
..."INTO Maps "
..."(Map) "
..."VALUES('%s');";

char mysql_maps_insert[] = 
"INSERT IGNORE "
..."INTO Maps "
..."(Map) "
..."VALUES('%s');";


// Times
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
..."CONSTRAINT PK_Times PRIMARY KEY (TimeID), "
..."CONSTRAINT FK_Times_SteamID FOREIGN KEY (SteamID) REFERENCES Players (SteamID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_Times_Map FOREIGN KEY (Map) REFERENCES Maps (Map) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_times_createindex_mapsteamid[] = 
"CREATE INDEX IF NOT EXISTS IX_MapSteamID "
..."ON Times (Map, SteamID);";

char sql_times_insert[] = 
"INSERT "
..."INTO Times "
..."(SteamID, Map, RunTime, Teleports, TheoreticalRunTime) "
..."VALUES('%s', '%s', %f, %d, %f);";

char sql_times_getpb[] = 
"SELECT MIN(RunTime), Teleports, TheoreticalRunTime "
..."FROM Times "
..."WHERE SteamID='%s' AND Map='%s' "
..."GROUP BY Map;";

char sql_times_getpbpro[] = 
"SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE SteamID='%s' AND Map='%s' AND Teleports=0 "
..."GROUP BY Map;";

char sql_times_gettop[] = 
"SELECT Players.Alias, MIN(Times.RunTime), Times.Teleports, Times.TheoreticalRunTime, Created "
..."FROM Times "
..."INNER JOIN Players ON Players.SteamID=Times.SteamID "
..."WHERE Times.Map='%s' "
..."GROUP BY Players.SteamID "
..."ORDER BY Times.RunTime ASC "
..."LIMIT %d;";

char sql_times_gettoppro[] = 
"SELECT Players.Alias, MIN(Times.RunTime), Created "
..."FROM Times "
..."INNER JOIN Players ON Players.SteamID=Times.SteamID "
..."WHERE Times.Map='%s' AND Times.Teleports=0 "
..."GROUP BY Players.SteamID "
..."ORDER BY Times.RunTime ASC "
..."LIMIT %d;";

char sql_times_getrank[] = 
"SELECT COUNT(*), MIN(RunTime)"
..."FROM Times "
..."WHERE RunTime <= "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE SteamID='%s' AND Map='%s' "
..."GROUP BY SteamID) "
..."AND Map='%s' "
..."GROUP BY SteamID;";

char sql_times_getrankpro[] = 
"SELECT COUNT(*), MIN(RunTime)"
..."FROM Times "
..."WHERE RunTime <= "
..."(SELECT MIN(RunTime) "
..."FROM Times "
..."WHERE SteamID='%s' AND Map='%s' AND Teleports=0 "
..."GROUP BY SteamID) "
..."AND Map='%s' AND Teleports=0 "
..."GROUP BY SteamID;";

char sql_times_getcompletions[] = 
"SELECT COUNT(DISTINCT SteamID) "
..."FROM Times "
..."WHERE Map='%s';";

char sql_times_getcompletionspro[] = 
"SELECT COUNT(DISTINCT SteamID) "
..."FROM Times "
..."WHERE Map='%s' AND Teleports=0;"; 