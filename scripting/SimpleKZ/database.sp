/*	database.sp
	
	Optional database for SimpleKZ.
*/


/*===============================  SQL Statements  ===============================*/

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



/*===============================  General  ===============================*/

void DB_SetupDatabase() {
	char error[255];
	gH_DB = SQL_Connect("simplekz", true, error, sizeof(error));
	if (gH_DB == INVALID_HANDLE) {
		PrintToServer("[SimpleKZ] Database connection unsuccessful: %s \n[SimpleKZ] Proceeding without database.", error);
		return;
	}
	
	char databaseType[8];
	SQL_ReadDriver(gH_DB, databaseType, sizeof(databaseType));
	if (strcmp(databaseType, "sqlite", false) == 0) {
		g_DBType = SQLITE;
	}
	else if (strcmp(databaseType, "mysql", false) == 0) {
		g_DBType = MYSQL;
	}
	else {
		PrintToServer("[SimpleKZ] Invalid database driver (use SQLite or MySQL).");
		return;
	}
	
	gB_ConnectedToDB = true;
	GetClientSteamIDAll(); // Ensures these are set for already connected clients (e.g. on plugin reload)
	DB_CreateTables();
}

void DB_CreateTables() {
	Transaction txn = SQL_CreateTransaction();
	txn.AddQuery(sql_players_create);
	txn.AddQuery(sql_preferences_create);
	txn.AddQuery(sql_maps_create);
	if (g_DBType == SQLITE) {
		txn.AddQuery(sqlite_times_create);
	}
	else if (g_DBType == MYSQL) {
		txn.AddQuery(mysql_times_create);
	}
	txn.AddQuery(sql_times_createindex_mapsteamid);
	SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic);
}

// Error check callback for queries don't return any results
public void DB_Callback_Generic(Handle database, Handle results, const char[] error, int client) {
	if (results == INVALID_HANDLE) {
		SetFailState("[SimpleKZ] Database query error: %s", error);
	}
}

// Error report callback for failed txns
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("[SimpleKZ] Database txn error: %s", error);
}



/*===============================  Players  ===============================*/

void DB_SavePlayerInfo(int client) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512], clientName[MAX_NAME_LENGTH], clientNameEscaped[MAX_NAME_LENGTH * 2 + 1];
	GetClientName(client, clientName, MAX_NAME_LENGTH);
	SQL_EscapeString(gH_DB, clientName, clientNameEscaped, MAX_NAME_LENGTH * 2 + 1);
	
	if (g_DBType == SQLITE) {
		Transaction txn = SQL_CreateTransaction();
		// UPDATE OR IGNORE
		FormatEx(query, sizeof(query), sql_players_update, clientNameEscaped, gC_Country[client], gC_SteamID[client]);
		txn.AddQuery(query);
		// INSERT OR IGNORE
		FormatEx(query, sizeof(query), sql_players_insert, clientNameEscaped, gC_Country[client], gC_SteamID[client]);
		txn.AddQuery(query);
		SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic, 0, DBPrio_High);
	}
	else if (g_DBType == MYSQL) {
		FormatEx(query, sizeof(query), mysql_players_saveinfo, gC_SteamID[client], clientNameEscaped, gC_Country[client]);
		SQL_TQuery(gH_DB, DB_Callback_Generic, query, 0, DBPrio_High);
	}
}



/*===============================  Preferences  ===============================*/

void DB_LoadPreferences(int client) {
	if (!gB_ConnectedToDB) {
		SetDefaultPreferences(client);
		return;
	}
	
	char query[512];
	FormatEx(query, sizeof(query), sql_preferences_get, gC_SteamID[client]);
	SQL_TQuery(gH_DB, DB_Callback_LoadPreferences, query, client, DBPrio_High);
}

public void DB_Callback_LoadPreferences(Handle db, Handle results, const char[] error, int client) {
	if (SQL_GetRowCount(results) == 0) {
		SetDefaultPreferences(client);
		
		char query[512];
		FormatEx(query, sizeof(query), sql_preferences_insert, gC_SteamID[client]);
		SQL_TQuery(gH_DB, DB_Callback_Generic, query, client, DBPrio_High);
	}
	else if (SQL_FetchRow(results)) {
		gB_ShowingTeleportMenu[client] = view_as<bool>(SQL_FetchInt(results, 0));
		gB_ShowingInfoPanel[client] = view_as<bool>(SQL_FetchInt(results, 1));
		gB_ShowingKeys[client] = view_as<bool>(SQL_FetchInt(results, 2));
		gB_ShowingPlayers[client] = view_as<bool>(SQL_FetchInt(results, 3));
		gB_ShowingWeapon[client] = view_as<bool>(SQL_FetchInt(results, 4));
		int pistolNumber = SQL_FetchInt(results, 5);
		if (pistolNumber >= NUMBER_OF_PISTOLS) {
			pistolNumber = 0;
		}
		gI_Pistol[client] = pistolNumber;
	}
}

void DB_UpdatePreferences(int client) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	FormatEx(query, sizeof(query), 
		sql_preferences_update, 
		BoolToInt(gB_ShowingTeleportMenu[client]), 
		BoolToInt(gB_ShowingInfoPanel[client]), 
		BoolToInt(gB_ShowingKeys[client]), 
		BoolToInt(gB_ShowingPlayers[client]), 
		BoolToInt(gB_ShowingWeapon[client]), 
		gI_Pistol[client], 
		gC_SteamID[client]);
	SQL_TQuery(gH_DB, DB_Callback_Generic, query, client, DBPrio_High);
}



/*===============================  Maps  ===============================*/

void DB_SaveMapInfo() {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	if (g_DBType == SQLITE) {
		FormatEx(query, sizeof(query), sqlite_maps_insert, gC_CurrentMap);
		SQL_TQuery(gH_DB, DB_Callback_Generic, query);
	}
	else if (g_DBType == MYSQL) {
		FormatEx(query, sizeof(query), mysql_maps_insert, gC_CurrentMap);
		SQL_TQuery(gH_DB, DB_Callback_Generic, query);
	}
}



/*===============================  End Time Processing  ===============================*/

void DB_ProcessEndTimer(int client) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	// Save time to DB
	FormatEx(query, sizeof(query), sql_times_insert, 
		gC_SteamID[client], gC_CurrentMap, gF_CurrentTime[client], gI_TeleportsUsed[client], (gF_CurrentTime[client] - gF_WastedTime[client]));
	SQL_TQuery(gH_DB, DB_Callback_Generic, query);
}



/*===============================  Print Personal Bests  ===============================*/

void DB_PrintPBs(int client, int target, const char[] map) {
	if (!gB_ConnectedToDB) {
		PrintNoDBMessage(client);
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(target);
	data.WriteString(map);
	
	Transaction txn = SQL_CreateTransaction();
	char query[512];
	
	// Get PB
	FormatEx(query, sizeof(query), sql_times_getpb, gC_SteamID[target], map);
	txn.AddQuery(query);
	// Get Rank
	FormatEx(query, sizeof(query), sql_times_getrank, gC_SteamID[target], map, map);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_times_getcompletions, map);
	txn.AddQuery(query);
	
	// Get Pro PB
	FormatEx(query, sizeof(query), sql_times_getpbpro, gC_SteamID[target], map);
	txn.AddQuery(query);
	// Get Pro Rank
	FormatEx(query, sizeof(query), sql_times_getrankpro, gC_SteamID[target], map, map);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_times_getcompletionspro, map);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintPBs, DB_TxnFailure_Generic, data);
}

public void DB_TxnSuccess_PrintPBs(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int target = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
	bool hasPB = false;
	bool hasPBPro = false;
	
	float runTime;
	int teleportsUsed;
	float theoreticalRunTime;
	int rank;
	int maxRank;
	
	float runTimePro;
	int rankPro;
	int maxRankPro;
	
	if (target == client) {
		PrintToChat(client, "[\x06KZ\x01] Personal Best Times on \x05%s\x01", map);
	}
	else {
		char targetName[MAX_NAME_LENGTH];
		GetClientName(target, targetName, MAX_NAME_LENGTH);
		PrintToChat(client, "[\x06KZ\x01] Best Times by \x05%s\x01 on \x05%s\x01", targetName, map);
	}
	
	// Get PB info from results
	if (SQL_GetRowCount(results[0]) > 0) {
		hasPB = true;
		
		SQL_FetchRow(results[0]);
		runTime = SQL_FetchFloat(results[0], 0);
		teleportsUsed = SQL_FetchInt(results[0], 1);
		theoreticalRunTime = SQL_FetchFloat(results[0], 2);
		
		SQL_FetchRow(results[1]);
		rank = SQL_FetchInt(results[1], 0);
		
		SQL_FetchRow(results[2]);
		maxRank = SQL_FetchInt(results[2], 0);
	}
	if (SQL_GetRowCount(results[3]) > 0) {
		hasPBPro = true;
		
		SQL_FetchRow(results[3]);
		runTimePro = SQL_FetchFloat(results[3], 0);
		
		SQL_FetchRow(results[4]);
		rankPro = SQL_FetchInt(results[4], 0);
		
		SQL_FetchRow(results[5]);
		maxRankPro = SQL_FetchInt(results[5], 0);
	}
	
	// Print PB Info
	if (!hasPB) {
		PrintToChat(client, "  No times by you were found!");
	}
	else if (!hasPBPro) {
		PrintToChat(client, 
			"  \x09MAP PB\x01: %s (\x09%d\x01 TP | \x08%s\x01) - #\x05%d\x01/%d", 
			FormatTimeFloat(runTime), teleportsUsed, FormatTimeFloat(theoreticalRunTime), rank, maxRank);
		PrintToChat(client, 
			"  \x0BPRO PB\x01: None!");
	}
	else if (teleportsUsed == 0) {
		PrintToChat(client, 
			"  \x09MAP PB\x01: %s - #\x05%d\x01/%d (\x0BPRO\x01 #\x05%d\x01/%d)", 
			FormatTimeFloat(runTime), rank, maxRank, rankPro, maxRankPro);
	}
	else {
		PrintToChat(client, 
			"  \x09MAP PB\x01: %s (\x09%d\x01 TP | \x08%s\x01) - #\x05%d\x01/%d", 
			FormatTimeFloat(runTime), teleportsUsed, FormatTimeFloat(theoreticalRunTime), rank, maxRank);
		PrintToChat(client, 
			"  \x0BPRO PB\x01: %s - #\x05%d\x01/%d", 
			FormatTimeFloat(runTimePro), rankPro, maxRankPro);
	}
}



/*===============================  Print Map Records  ===============================*/

void DB_PrintMapRecords(int client, const char[] map) {
	if (!gB_ConnectedToDB) {
		PrintNoDBMessage(client);
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	
	Transaction txn = SQL_CreateTransaction();
	char query[512];
	
	// Get Map Top
	FormatEx(query, sizeof(query), sql_times_gettop, map, 1);
	txn.AddQuery(query);
	// Get PRO Top
	FormatEx(query, sizeof(query), sql_times_gettoppro, map, 1);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintMapRecords, DB_TxnFailure_Generic, data);
}

public void DB_TxnSuccess_PrintMapRecords(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
	bool hasRecord = false;
	bool hasRecordPro = false;
	
	char recordHolder[33];
	float runTime;
	int teleportsUsed;
	
	char recordHolderPro[33];
	float runTimePro;
	
	PrintToChat(client, "[\x06KZ\x01] Server Records for \x05%s\x01", map);
	
	// Get WR info from results
	if (SQL_GetRowCount(results[0]) > 0) {
		hasRecord = true;
		
		SQL_FetchRow(results[0]);
		SQL_FetchString(results[0], 0, recordHolder, sizeof(recordHolder));
		runTime = SQL_FetchFloat(results[0], 1);
		teleportsUsed = SQL_FetchInt(results[0], 2);
	}
	if (SQL_GetRowCount(results[1]) > 0) {
		hasRecordPro = true;
		
		SQL_FetchRow(results[1]);
		SQL_FetchString(results[1], 0, recordHolderPro, sizeof(recordHolderPro));
		runTimePro = SQL_FetchFloat(results[1], 1);
	}
	
	// Print WR info
	if (!hasRecord) {
		PrintToChat(client, "  No times found!");
	}
	else if (!hasRecordPro) {
		PrintToChat(client, 
			"  \x09MAP RECORD\x01: %s (\x09%d\x01 TP) by \x05%s\x01", 
			FormatTimeFloat(runTime), teleportsUsed, recordHolder);
		PrintToChat(client, "  \x0BPRO RECORD\x01: None!");
	}
	else if (teleportsUsed == 0) {
		PrintToChat(client, 
			"  \x09MAP RECORD\x01: %s (\x0BPRO\x01) by \x05%s\x01", 
			FormatTimeFloat(runTimePro), recordHolderPro);
	}
	else {
		PrintToChat(client, 
			"  \x09MAP RECORD\x01: %s (\x09%d\x01 TP) by \x05%s\x01", 
			FormatTimeFloat(runTime), teleportsUsed, recordHolder);
		PrintToChat(client, 
			"  \x0BPRO RECORD\x01: %s by \x05%s\x01", 
			FormatTimeFloat(runTimePro), recordHolderPro);
	}
}



/*===============================  Map Top  ===============================*/

void DB_OpenMapTop(int client, const char[] map) {
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	
	char query[512];
	FormatEx(query, sizeof(query), sql_times_gettop, map, 20);
	SQL_TQuery(gH_DB, DB_Callback_OpenMapTop, query, data);
}

public void DB_Callback_OpenMapTop(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
	if (SQL_GetRowCount(results) == 0) {
		PrintToChat(client, "[\x06KZ\x01] No times were found for map \x05%s\x01.", map);
		OpenMapTopMenu(client);
		return;
	}
	
	RemoveAllMenuItems(gH_MapTopSubmenu[client]);
	SetMenuTitle(gH_MapTopSubmenu[client], 
		"Top 20 Times on %s\n             Time            TP      Player", 
		map);
	
	// Add menu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results)) {
		rank++;
		
		char playerString[33];
		SQL_FetchString(results, 0, playerString, sizeof(playerString));
		
		FormatEx(newMenuItem, sizeof(newMenuItem), 
			"[%02d]  %13s %-8d %s", 
			rank, FormatTimeFloat(SQL_FetchFloat(results, 1)), SQL_FetchInt(results, 2), playerString);
		
		AddMenuItem(gH_MapTopSubmenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_MapTopSubmenu[client], client, MENU_TIME_FOREVER);
}

void DB_OpenMapTopPro(int client, const char[] map) {
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	
	char query[512];
	FormatEx(query, sizeof(query), sql_times_gettoppro, map, 20);
	SQL_TQuery(gH_DB, DB_Callback_OpenMapTopPro, query, data);
}

public void DB_Callback_OpenMapTopPro(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
	if (SQL_GetRowCount(results) == 0) {
		PrintToChat(client, "[\x06KZ\x01] No \x0BPRO\x01 times were found for map \x05%s\x01.", map);
		OpenMapTopMenu(client);
		return;
	}
	
	RemoveAllMenuItems(gH_MapTopSubmenu[client]);
	SetMenuTitle(gH_MapTopSubmenu[client], 
		"Top 20 PRO Times on %s\n             Time            Player", 
		map);
	
	// Add menu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results)) {
		rank++;
		
		char playerString[33];
		SQL_FetchString(results, 0, playerString, sizeof(playerString));
		
		FormatEx(newMenuItem, sizeof(newMenuItem), 
			"[%02d]  %13s %s", 
			rank, FormatTimeFloat(SQL_FetchFloat(results, 1)), playerString);
		
		AddMenuItem(gH_MapTopSubmenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_MapTopSubmenu[client], client, MENU_TIME_FOREVER);
} 