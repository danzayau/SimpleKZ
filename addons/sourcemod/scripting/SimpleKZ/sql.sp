/*	sql.sp
	
	SQL statement templates for database.
*/


/*===============================  Players Table  ===============================*/

char sql_players_create[] = 
"CREATE TABLE IF NOT EXISTS Players ("
..."SteamID VARCHAR(24) NOT NULL, "
..."Alias VARCHAR(32) NOT NULL, "
..."Country VARCHAR(45) NOT NULL, "
..."FirstSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."LastSeen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."CONSTRAINT PK_Player PRIMARY KEY (SteamID));";

char sqlite_players_insert[] = 
"INSERT OR IGNORE INTO Players "
..."(Alias, Country, SteamID) "
..."VALUES('%s', '%s', '%s');";

char sqlite_players_update[] = 
"UPDATE OR IGNORE Players "
..."SET Alias='%s', Country='%s', LastSeen=CURRENT_TIMESTAMP "
..."WHERE SteamID='%s';";

char mysql_players_saveinfo[] = 
"INSERT INTO Players "
..."(SteamID, Alias, Country) "
..."VALUES('%s', '%s', '%s') "
..."ON DUPLICATE KEY UPDATE "
..."SteamID=VALUES(SteamID), Alias=VALUES(Alias), Country=VALUES(Country);";



/*===============================  Preferences Table  ===============================*/

char sql_preferences_create[] = 
"CREATE TABLE IF NOT EXISTS Preferences ("
..."SteamID VARCHAR(24) NOT NULL, "
..."ShowingTeleportMenu TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingInfoPanel TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingKeys TINYINT(1) NOT NULL DEFAULT '0', "
..."ShowingPlayers TINYINT(1) NOT NULL DEFAULT '1', "
..."ShowingWeapon TINYINT(1) NOT NULL DEFAULT '1', "
..."AutoRestart TINYINT(1) NOT NULL DEFAULT '0', "
..."SlayOnEnd TINYINT(1) NOT NULL DEFAULT '0', "
..."Pistol TINYINT UNSIGNED NOT NULL DEFAULT '0', "
..."CONSTRAINT PK_Preferences PRIMARY KEY (SteamID), "
..."CONSTRAINT FK_Preferences_SteamID FOREIGN KEY (SteamID) REFERENCES Players (SteamID) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_preferences_alter1[] = 
"ALTER TABLE Preferences "
..."ADD MovementStyle TINYINT UNSIGNED NOT NULL DEFAULT '0';";

char sql_preferences_insert[] = 
"INSERT "
..."INTO Preferences "
..."(SteamID, MovementStyle) "
..."VALUES('%s', %d);";

char sql_preferences_update[] = 
"UPDATE Preferences "
..."SET ShowingTeleportMenu=%d, ShowingInfoPanel=%d, ShowingKeys=%d, ShowingPlayers=%d, ShowingWeapon=%d, AutoRestart=%d, SlayOnEnd=%d, Pistol=%d, MovementStyle=%d "
..."WHERE SteamID='%s';";

char sql_preferences_get[] = 
"SELECT ShowingTeleportMenu, ShowingInfoPanel, ShowingKeys, ShowingPlayers, ShowingWeapon, AutoRestart, SlayOnEnd, Pistol, MovementStyle "
..."FROM Preferences "
..."WHERE SteamID='%s';"; 