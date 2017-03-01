/*	sql.sp
	
	SQL statement templates for database.
*/


/*===============================  Players Table  ===============================*/

char sqlite_players_create[] = 
"CREATE TABLE IF NOT EXISTS Players ("
..."PlayerID INTEGER, "
..."SteamID VARCHAR(24) NOT NULL UNIQUE, "
..."Alias VARCHAR(32) NOT NULL, "
..."Country VARCHAR(45) NOT NULL, "
..."FirstSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."LastSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Player PRIMARY KEY (PlayerID));";

char mysql_players_create[] = 
"CREATE TABLE IF NOT EXISTS Players ("
..."PlayerID INTEGER UNSIGNED NOT NULL AUTO_INCREMENT, "
..."SteamID VARCHAR(24) NOT NULL UNIQUE, "
..."Alias VARCHAR(32) NOT NULL, "
..."Country VARCHAR(45) NOT NULL, "
..."FirstSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."LastSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Player PRIMARY KEY (PlayerID));";

char sqlite_players_insert[] = 
"INSERT OR IGNORE INTO Players "
..."(Alias, Country, SteamID) "
..."VALUES('%s', '%s', '%s');";

char sqlite_players_update[] = 
"UPDATE OR IGNORE Players "
..."SET Alias='%s', Country='%s', LastSeen=CURRENT_TIMESTAMP "
..."WHERE SteamID='%s';";

char mysql_players_upsert[] = 
"INSERT INTO Players "
..."(Alias, Country, SteamID) "
..."VALUES('%s', '%s', '%s') "
..."ON DUPLICATE KEY UPDATE "
..."SteamID=VALUES(SteamID), Alias=VALUES(Alias), Country=VALUES(Country), LastSeen=CURRENT_TIMESTAMP;";

char sql_players_getplayerid[] = 
"SELECT PlayerID "
..."FROM Players "
..."WHERE SteamID='%s';";



/*===============================  Options Table  ===============================*/

char sqlite_options_create[] = 
"CREATE TABLE IF NOT EXISTS Options ("
..."PlayerID INTEGER, "
..."Style TINYINT UNSIGNED NOT NULL, "
..."ShowingTeleportMenu TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingInfoPanel TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingKeys TINYINT(1) NOT NULL DEFAULT '0', "
..."ShowingPlayers TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingWeapon TINYINT(1) NOT NULL DEFAULT '1', "
..."AutoRestart TINYINT(1) NOT NULL DEFAULT '0', "
..."SlayOnEnd TINYINT(1) NOT NULL DEFAULT '0', "
..."Pistol TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."CheckpointMessages TINYINT(1) NOT NULL DEFAULT '0', "
..."CheckpointSounds TINYINT(1) NOT NULL DEFAULT '0', "
..."TeleportSounds TINYINT(1) NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Options PRIMARY KEY (PlayerID), "
..."CONSTRAINT FK_Options_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE);";

char mysql_options_create[] = 
"CREATE TABLE IF NOT EXISTS Options ("
..."PlayerID INTEGER UNSIGNED NOT NULL, "
..."Style TINYINT UNSIGNED NOT NULL, "
..."ShowingTeleportMenu TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingInfoPanel TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingKeys TINYINT(1) NOT NULL DEFAULT '0', "
..."ShowingPlayers TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingWeapon TINYINT(1) NOT NULL DEFAULT '1', "
..."AutoRestart TINYINT(1) NOT NULL DEFAULT '0', "
..."SlayOnEnd TINYINT(1) NOT NULL DEFAULT '0', "
..."Pistol TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."CheckpointMessages TINYINT(1) NOT NULL DEFAULT '0', "
..."CheckpointSounds TINYINT(1) NOT NULL DEFAULT '0', "
..."TeleportSounds TINYINT(1) NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Options PRIMARY KEY (PlayerID), "
..."CONSTRAINT FK_Options_PlayerID FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_options_insert[] = 
"INSERT "
..."INTO Options "
..."(PlayerID, Style) "
..."VALUES(%d, %d);";

char sql_options_update[] = 
"UPDATE Options "
..."SET Style=%d, ShowingTeleportMenu=%d, ShowingInfoPanel=%d, ShowingKeys=%d, ShowingPlayers=%d, ShowingWeapon=%d, AutoRestart=%d, SlayOnEnd=%d, Pistol=%d, CheckpointMessages=%d, CheckpointSounds=%d, TeleportSounds=%d "
..."WHERE PlayerID=%d;";

char sql_options_get[] = 
"SELECT Style, ShowingTeleportMenu, ShowingInfoPanel, ShowingKeys, ShowingPlayers, ShowingWeapon, AutoRestart, SlayOnEnd, Pistol, CheckpointMessages, CheckpointSounds, TeleportSounds "
..."FROM Options "
..."WHERE PlayerID=%d;"; 