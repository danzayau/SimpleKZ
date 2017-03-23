/*	sql.sp
	
	SQL statement templates for database.
*/


/*===============================  Players Table  ===============================*/

char sqlite_players_create[] = 
"CREATE TABLE IF NOT EXISTS Players ("
..."PlayerID INTEGER, "
..."SteamID64 INTEGER NOT NULL UNIQUE, "
..."Alias TEXT, "
..."Country TEXT, "
..."IP TEXT, "
..."FirstSeen INTEGER DEFAULT CURRENT_TIMESTAMP, "
..."LastSeen INTEGER DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Player PRIMARY KEY (PlayerID));";

char mysql_players_create[] = 
"CREATE TABLE IF NOT EXISTS Players ("
..."PlayerID INTEGER UNSIGNED AUTO_INCREMENT, "
..."SteamID64 BIGINT UNSIGNED NOT NULL UNIQUE, "
..."Alias VARCHAR(32), "
..."Country VARCHAR(45), "
..."IP VARCHAR(15), "
..."FirstSeen TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
..."LastSeen TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Player PRIMARY KEY (PlayerID));";

char sqlite_players_insert[] = 
"INSERT OR IGNORE INTO Players (Alias, Country, IP, SteamID64) "
..."VALUES ('%s', '%s', '%s', %s);";

char sqlite_players_update[] = 
"UPDATE OR IGNORE Players "
..."SET Alias='%s', Country='%s', IP='%s', LastSeen=CURRENT_TIMESTAMP "
..."WHERE SteamID64=%s;";

char mysql_players_upsert[] = 
"INSERT INTO Players (Alias, Country, IP, SteamID64) "
..."VALUES ('%s', '%s', '%s', %s) "
..."ON DUPLICATE KEY UPDATE "
..."SteamID64=VALUES(SteamID64), Alias=VALUES(Alias), Country=VALUES(Country), IP=VALUES(IP), LastSeen=CURRENT_TIMESTAMP;";

char sql_players_getplayerid[] = 
"SELECT PlayerID "
..."FROM Players "
..."WHERE SteamID64=%s;";



/*===============================  Options Table  ===============================*/

char sqlite_options_create[] = 
"CREATE TABLE IF NOT EXISTS Options ("
..."PlayerID INTEGER, "
..."Style INTEGER NOT NULL DEFAULT '0', "
..."ShowingTeleportMenu INTEGER NOT NULL DEFAULT '1', "
..."ShowingInfoPanel INTEGER NOT NULL DEFAULT '1', "
..."ShowingKeys INTEGER NOT NULL DEFAULT '0', "
..."ShowingPlayers INTEGER NOT NULL DEFAULT '1', "
..."ShowingWeapon INTEGER NOT NULL DEFAULT '1', "
..."AutoRestart INTEGER NOT NULL DEFAULT '0', "
..."SlayOnEnd INTEGER NOT NULL DEFAULT '0', "
..."Pistol INTEGER NOT NULL DEFAULT '0', "
..."CheckpointMessages INTEGER NOT NULL DEFAULT '0', "
..."CheckpointSounds INTEGER NOT NULL DEFAULT '0', "
..."TeleportSounds INTEGER NOT NULL DEFAULT '0', "
..."TimerText INTEGER NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Options PRIMARY KEY (PlayerID), "
..."CONSTRAINT FK_Options_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE);";

char mysql_options_create[] = 
"CREATE TABLE IF NOT EXISTS Options ("
..."PlayerID INTEGER UNSIGNED, "
..."Style TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."ShowingTeleportMenu TINYINT UNSIGNED NOT NULL DEFAULT '1', "
..."ShowingInfoPanel TINYINT UNSIGNED NOT NULL DEFAULT '1', "
..."ShowingKeys TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."ShowingPlayers TINYINT UNSIGNED NOT NULL DEFAULT '1', "
..."ShowingWeapon TINYINT UNSIGNED NOT NULL DEFAULT '1', "
..."AutoRestart TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."SlayOnEnd TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."Pistol TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."CheckpointMessages TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."CheckpointSounds TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."TeleportSounds TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."TimerText TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Options PRIMARY KEY (PlayerID), "
..."CONSTRAINT FK_Options_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_options_insert[] = 
"INSERT INTO Options (PlayerID, Style) "
..."VALUES (%d, %d);";

char sql_options_update[] = 
"UPDATE Options "
..."SET Style=%d, ShowingTeleportMenu=%d, ShowingInfoPanel=%d, ShowingKeys=%d, ShowingPlayers=%d, ShowingWeapon=%d, AutoRestart=%d, SlayOnEnd=%d, Pistol=%d, CheckpointMessages=%d, CheckpointSounds=%d, TeleportSounds=%d, TimerText=%d "
..."WHERE PlayerID=%d;";

char sql_options_get[] = 
"SELECT Style, ShowingTeleportMenu, ShowingInfoPanel, ShowingKeys, ShowingPlayers, ShowingWeapon, AutoRestart, SlayOnEnd, Pistol, CheckpointMessages, CheckpointSounds, TeleportSounds, TimerText "
..."FROM Options "
..."WHERE PlayerID=%d;";



/*===============================  Maps Table  ===============================*/

char sqlite_maps_create[] = 
"CREATE TABLE IF NOT EXISTS Maps ("
..."MapID INTEGER, "
..."Name VARCHAR(32) NOT NULL UNIQUE, "
..."LastPlayed INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Maps PRIMARY KEY (MapID));";

char mysql_maps_create[] = 
"CREATE TABLE IF NOT EXISTS Maps ("
..."MapID INTEGER UNSIGNED AUTO_INCREMENT, "
..."Name VARCHAR(32) NOT NULL UNIQUE, "
..."InRankedPool TINYINT NOT NULL DEFAULT '0', "
..."LastPlayed TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Maps PRIMARY KEY (MapID));";

char sqlite_maps_insert[] = 
"INSERT OR IGNORE INTO Maps (Name) "
..."VALUES ('%s');";

char sqlite_maps_update[] = 
"UPDATE OR IGNORE Maps "
..."SET LastPlayed=CURRENT_TIMESTAMP "
..."WHERE Name='%s';";

char mysql_maps_upsert[] = 
"INSERT INTO Maps (Name) "
..."VALUES ('%s') "
..."ON DUPLICATE KEY UPDATE "
..."LastPlayed=CURRENT_TIMESTAMP;";

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
..."PlayerID INTEGER NOT NULL, "
..."MapID INTEGER NOT NULL, "
..."Course INTEGER NOT NULL, "
..."Style INTEGER NOT NULL, "
..."RunTime INTEGER NOT NULL, "
..."Teleports INTEGER NOT NULL, "
..."TheoreticalRunTime INTEGER NOT NULL, "
..."Created INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Times PRIMARY KEY (TimeID), "
..."CONSTRAINT FK_Times_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_Times_MapID FOREIGN KEY (MapID) REFERENCES Maps (MapID) ON UPDATE CASCADE ON DELETE CASCADE);";

char mysql_times_create[] = 
"CREATE TABLE IF NOT EXISTS Times ("
..."TimeID INTEGER UNSIGNED AUTO_INCREMENT, "
..."PlayerID INTEGER UNSIGNED NOT NULL, "
..."MapID INTEGER UNSIGNED NOT NULL, "
..."Course TINYINT UNSIGNED NOT NULL, "
..."Style TINYINT UNSIGNED NOT NULL, "
..."RunTime INTEGER UNSIGNED NOT NULL, "
..."Teleports SMALLINT UNSIGNED NOT NULL, "
..."TheoreticalRunTime INTEGER UNSIGNED NOT NULL, "
..."Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Times PRIMARY KEY (TimeID), "
..."CONSTRAINT FK_Times_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_Times_MapID FOREIGN KEY (MapID) REFERENCES Maps (MapID) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_times_insert[] = 
"INSERT INTO Times (PlayerID, MapID, Course, Style, RunTime, Teleports, TheoreticalRunTime) "
..."VALUES (%d, %d, %d, %d, %d, %d, %d);"; 