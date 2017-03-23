/*	database.sp
	
	Database interaction.
*/


/*===============================  General  ===============================*/

void DB_CreateTables() {
	SQL_LockDatabase(gH_DB);
	
	// Create/alter database tables
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			SQL_FastQuery(gH_DB, sqlite_maps_alter1);
		}
		case DatabaseType_MySQL: {
			SQL_FastQuery(gH_DB, mysql_maps_alter1);
		}
	}
	
	SQL_UnlockDatabase(gH_DB);
}

/* Error report callback for failed transactions */
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("%T", "Database Transaction Error", LANG_SERVER, error);
}

/* Used to find a PlayerID from an input string using an already written method */
void DB_FindPlayer(const char[] playerSearch, SQLTxnSuccess onSuccess, any data = 0, DBPriority priority = DBPrio_Normal) {
	char query[512], playerEscaped[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(gH_DB, playerSearch, playerEscaped, sizeof(playerEscaped));
	
	String_ToLower(playerEscaped, playerEscaped, sizeof(playerEscaped));
	
	Transaction txn = SQL_CreateTransaction();
	
	// Look for player name and retrieve their PlayerID
	FormatEx(query, sizeof(query), sql_players_findid, playerEscaped, playerEscaped);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, onSuccess, DB_TxnFailure_Generic, data, priority);
}

/* Used to find a MapID from an input string using an already written method */
void DB_FindMap(const char[] mapSearch, SQLTxnSuccess onSuccess, any data = 0, DBPriority priority = DBPrio_Normal) {
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, mapSearch, mapEscaped, sizeof(mapEscaped));
	
	Transaction txn = SQL_CreateTransaction();
	
	// Look for map name and retrieve it's MapID
	FormatEx(query, sizeof(query), sql_maps_findid, mapEscaped, mapEscaped);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, onSuccess, DB_TxnFailure_Generic, data, priority);
}

/* Used to find a PlayerID MapID from input strings using an already written method */
void DB_FindPlayerAndMap(const char[] playerSearch, const char[] mapSearch, SQLTxnSuccess onSuccess, any data = 0, DBPriority priority = DBPrio_Normal) {
	char query[512], mapEscaped[129], playerEscaped[MAX_NAME_LENGTH * 2 + 1];
	SQL_EscapeString(gH_DB, playerSearch, playerEscaped, sizeof(playerEscaped));
	SQL_EscapeString(gH_DB, mapSearch, mapEscaped, sizeof(mapEscaped));
	
	String_ToLower(playerEscaped, playerEscaped, sizeof(playerEscaped));
	
	Transaction txn = SQL_CreateTransaction();
	
	// Look for player name and retrieve their PlayerID
	FormatEx(query, sizeof(query), sql_players_findid, playerEscaped, playerEscaped);
	txn.AddQuery(query);
	// Look for player name and retrieve their PlayerID
	FormatEx(query, sizeof(query), sql_players_findid, playerEscaped, playerEscaped);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, onSuccess, DB_TxnFailure_Generic, data, priority);
}



/*===============================  Maps  ===============================*/

void DB_UpdateRankedMapPool(int client) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	Handle file = OpenFile(FILE_PATH_MAPPOOL, "r");
	if (file == INVALID_HANDLE) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Failed to Open File", FILE_PATH_MAPPOOL);
		return;
	}
	
	char line[33], query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Reset all maps to be unranked
	txn.AddQuery(sql_maps_reset_mappool);
	// Insert/Update maps in mappool.cfg to be ranked
	while (ReadFileLine(file, line, sizeof(line))) {
		TrimString(line);
		if (line[0] == '\0' || line[0] == ';' || (line[0] == '/' && line[1] == '/')) {
			continue;
		}
		String_ToLower(line, line, sizeof(line));
		switch (g_DBType) {
			case DatabaseType_SQLite: {
				// UPDATE OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_updateranked, 1, line);
				txn.AddQuery(query);
				// INSERT OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_insertranked, 1, line);
				txn.AddQuery(query);
			}
			case DatabaseType_MySQL: {
				FormatEx(query, sizeof(query), mysql_maps_upsertranked, 1, line);
				txn.AddQuery(query);
			}
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_UpdateRankedMapPool, DB_TxnFailure_Generic, client, DBPrio_Low);
	
	CloseHandle(file);
}

public void DB_TxnSuccess_UpdateRankedMapPool(Handle db, int client, int numQueries, Handle[] results, any[] queryData) {
	PrintToServer("%T", "Map Pool Update Successful", LANG_SERVER);
	if (IsValidClient(client)) {
		PrintToChat(client, "%t", "Map Pool Update Successful");
	}
}



/*===============================  End Time Processing  ===============================*/

void DB_ProcessNewTime(int client, int playerID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(playerID);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteCell(runTimeMS);
	data.WriteCell(teleportsUsed);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get Top 2 PBs
	FormatEx(query, sizeof(query), sql_getpb, playerID, mapID, course, style, 2);
	txn.AddQuery(query);
	// Get Rank
	FormatEx(query, sizeof(query), sql_getmaprank, playerID, mapID, course, style, mapID, course, style);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_getlowestmaprank, mapID, course, style);
	txn.AddQuery(query);
	
	if (teleportsUsed == 0) {
		// Get Top 2 PRO PBs
		FormatEx(query, sizeof(query), sql_getpbpro, playerID, mapID, course, style, 2);
		txn.AddQuery(query);
		// Get PRO Rank
		FormatEx(query, sizeof(query), sql_getmaprankpro, playerID, mapID, course, style, mapID, course, style);
		txn.AddQuery(query);
		// Get Number of Players with PRO Times
		FormatEx(query, sizeof(query), sql_getlowestmaprankpro, mapID, course, style);
		txn.AddQuery(query);
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_ProcessTimerEnd, DB_TxnFailure_Generic, data, DBPrio_Normal);
}

public void DB_TxnSuccess_ProcessTimerEnd(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int playerID = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	int runTimeMS = data.ReadCell();
	int teleportsUsed = data.ReadCell();
	CloseHandle(data);
	
	// Client is no longer valid so don't continue
	if (!IsValidClient(client) || playerID != SimpleKZ_GetPlayerID(client)) {
		return;
	}
	
	float runTime = SimpleKZ_TimeIntToFloat(runTimeMS);
	
	bool newPB = false;
	bool firstTime = false;
	float improvement;
	int rank;
	int maxRank;
	
	bool newPBPro = false;
	bool firstTimePro = false;
	float improvementPro;
	int rankPro;
	int maxRankPro;
	
	// Check for new PB
	if (SQL_GetRowCount(results[0]) == 2) {
		SQL_FetchRow(results[0]);
		if (runTimeMS == SQL_FetchInt(results[0], 0)) {
			newPB = true;
			// Time they just beat is second row
			SQL_FetchRow(results[0]);
			improvement = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[0], 0) - runTimeMS);
		}
	}
	else {  // Only 1 row (the time they just got) so this is their first time
		newPB = true;
		firstTime = true;
	}
	
	// If new PB, get rank information
	if (newPB) {
		SQL_FetchRow(results[1]);
		rank = SQL_FetchInt(results[1], 0);
		SQL_FetchRow(results[2]);
		maxRank = SQL_FetchInt(results[2], 0);
	}
	
	// Repeat for PRO runs if necessary
	if (teleportsUsed == 0) {
		// Check for new PRO PB
		if (SQL_GetRowCount(results[3]) == 2) {
			SQL_FetchRow(results[3]);
			if (runTimeMS == SQL_FetchInt(results[3], 0)) {
				newPBPro = true;
				// Time they just beat is second row
				SQL_FetchRow(results[3]);
				improvementPro = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[3], 0) - runTimeMS);
			}
		}
		else {  // Only 1 row (the time they just got)
			newPBPro = true;
			firstTimePro = true;
		}
		// If new PB, get rank information
		if (newPBPro) {
			SQL_FetchRow(results[4]);
			rankPro = SQL_FetchInt(results[4], 0);
			SQL_FetchRow(results[5]);
			maxRankPro = SQL_FetchInt(results[5], 0);
		}
	}
	
	// Call OnNewPersonalBest forward (KZTimeType_Normal)
	if (newPB) {
		if (firstTime) {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, KZTimeType_Normal, true, runTime, -1.0, rank, maxRank);
		}
		else {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, KZTimeType_Normal, false, runTime, improvement, rank, maxRank);
		}
	}
	// Call OnNewPersonalBest forward (KZTimeType_Pro)
	if (newPBPro) {
		if (firstTimePro) {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, KZTimeType_Pro, true, runTime, -1.0, rankPro, maxRankPro);
		}
		else {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, KZTimeType_Pro, false, runTime, improvementPro, rankPro, maxRankPro);
		}
	}
	
	// Call OnNewRecord forward
	if ((newPB && rank == 1) && !(newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnNewRecord(client, mapID, course, style, KZRecordType_Map, runTime);
	}
	else if (!(newPB && rank == 1) && (newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnNewRecord(client, mapID, course, style, KZRecordType_Pro, runTime);
	}
	else if ((newPB && rank == 1) && (newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnNewRecord(client, mapID, course, style, KZRecordType_MapAndPro, runTime);
	}
	
	// Update PRO Completion [Standard] percentage in scoreboard
	if (style == KZStyle_Standard && course == 0 && firstTimePro) {
		DB_GetCompletion(client, client, KZStyle_Standard, false);
	}
}



/*===============================  Print Personal Bests  ===============================*/

void DB_PrintPBs(int client, int targetPlayerID, int mapID, int course, KZStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	char query[512];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Alias of PlayerID
	FormatEx(query, sizeof(query), sql_players_getalias, targetPlayerID);
	txn.AddQuery(query);
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	
	// Get PB
	FormatEx(query, sizeof(query), sql_getpb, targetPlayerID, mapID, course, style, 1);
	txn.AddQuery(query);
	// Get Rank
	FormatEx(query, sizeof(query), sql_getmaprank, targetPlayerID, mapID, course, style, mapID, course, style);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_getlowestmaprank, mapID, course, style);
	txn.AddQuery(query);
	
	// Get PRO PB
	FormatEx(query, sizeof(query), sql_getpbpro, targetPlayerID, mapID, course, style, 1);
	txn.AddQuery(query);
	// Get PRO Rank
	FormatEx(query, sizeof(query), sql_getmaprankpro, targetPlayerID, mapID, course, style, mapID, course, style);
	txn.AddQuery(query);
	// Get Number of Players with PRO Times
	FormatEx(query, sizeof(query), sql_getlowestmaprankpro, mapID, course, style);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintPBs, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintPBs(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	// Client is no longer valid so don't continue
	if (!IsValidClient(client)) {
		return;
	}
	
	char playerName[MAX_NAME_LENGTH], mapName[33];
	
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
	
	// Get Player Name from results
	if (SQL_FetchRow(results[0])) {
		SQL_FetchString(results[0], 0, playerName, sizeof(playerName));
	}
	// Get Map Name from results
	if (SQL_FetchRow(results[1])) {
		SQL_FetchString(results[1], 0, mapName, sizeof(mapName));
	}
	// Get PB info from results
	if (SQL_GetRowCount(results[2]) > 0) {
		hasPB = true;
		if (SQL_FetchRow(results[2])) {
			runTime = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[2], 0));
			teleportsUsed = SQL_FetchInt(results[2], 1);
			theoreticalRunTime = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[2], 2));
		}
		if (SQL_FetchRow(results[3])) {
			rank = SQL_FetchInt(results[3], 0);
		}
		if (SQL_FetchRow(results[4])) {
			maxRank = SQL_FetchInt(results[4], 0);
		}
	}
	// Get PB info (Pro) from results
	if (SQL_GetRowCount(results[5]) > 0) {
		hasPBPro = true;
		if (SQL_FetchRow(results[5])) {
			runTimePro = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[5], 0));
		}
		if (SQL_FetchRow(results[6])) {
			rankPro = SQL_FetchInt(results[6], 0);
		}
		if (SQL_FetchRow(results[7])) {
			maxRankPro = SQL_FetchInt(results[7], 0);
		}
	}
	
	// Print PB header to chat
	if (course == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "PB Header", playerName, mapName, gC_StylePhrases[style]);
	}
	else {
		CPrintToChat(client, "%t %t", "KZ Prefix", "PB Header (Bonus)", playerName, mapName, course, gC_StylePhrases[style]);
	}
	
	// Print PB times to chat
	if (!hasPB) {
		CPrintToChat(client, "  %t", "PB Time - No Times");
	}
	else if (!hasPBPro) {
		CPrintToChat(client, "  %t", "PB Time - Map", SimpleKZ_FormatTime(runTime), rank, maxRank, teleportsUsed, SimpleKZ_FormatTime(theoreticalRunTime));
		CPrintToChat(client, "  %t", "PB Time - No Pro Time");
	}
	else if (teleportsUsed == 0) {  // Their MAP PB has 0 teleports, and is therefore also their PRO PB
		CPrintToChat(client, "  %t", "PB Time - Map (Pro)", SimpleKZ_FormatTime(runTime), rank, maxRank, rankPro, maxRankPro);
	}
	else {
		CPrintToChat(client, "  %t", "PB Time - Map", SimpleKZ_FormatTime(runTime), rank, maxRank, teleportsUsed, SimpleKZ_FormatTime(theoreticalRunTime));
		CPrintToChat(client, "  %t", "PB Time - Pro", SimpleKZ_FormatTime(runTimePro), rankPro, maxRankPro);
	}
}

void DB_PrintPBs_FindMap(int client, int targetPlayerID, const char[] mapSearch, int course, KZStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(targetPlayerID);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindMap(mapSearch, DB_TxnSuccess_PrintPBs_FindMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintPBs_FindMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int targetPlayerID = data.ReadCell();
	char mapSearch[33];
	data.ReadString(mapSearch, sizeof(mapSearch));
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	// Client is no longer valid so don't continue
	if (!IsValidClient(client)) {
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0])) {  // Result is the MapID
		DB_PrintPBs(client, targetPlayerID, SQL_FetchInt(results[0], 0), course, style);
	}
}

void DB_PrintPBs_FindPlayerAndMap(int client, const char[] playerSearch, const char[] mapSearch, int course, KZStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(playerSearch);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindPlayerAndMap(playerSearch, mapSearch, DB_TxnSuccess_PrintPBs_FindPlayerAndMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintPBs_FindPlayerAndMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char playerSearch[MAX_NAME_LENGTH];
	data.ReadString(playerSearch, sizeof(playerSearch));
	char mapSearch[33];
	data.ReadString(mapSearch, sizeof(mapSearch));
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	// Client is no longer valid so don't continue
	if (!IsValidClient(client)) {
		return;
	}
	else if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Player Not Found", playerSearch);
		return;
	}
	else if (SQL_GetRowCount(results[1]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0]) && SQL_FetchRow(results[1])) {  // Results are Target PlayerID and MapID
		DB_PrintPBs(client, SQL_FetchInt(results[0], 0), SQL_FetchInt(results[1], 0), course, style);
	}
}



/*===============================  Print Records  ===============================*/

void DB_PrintRecords(int client, int mapID, int course, KZStyle style) {
	char query[512];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	// Get Map WR
	FormatEx(query, sizeof(query), sql_getmaptop, mapID, course, style, 1);
	txn.AddQuery(query);
	// Get PRO WR
	FormatEx(query, sizeof(query), sql_getmaptoppro, mapID, course, style, 1);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintRecords, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintRecords(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	char mapName[33];
	
	bool mapHasRecord = false;
	bool mapHasRecordPro = false;
	
	char recordHolder[33];
	float runTime;
	int teleportsUsed;
	
	char recordHolderPro[33];
	float runTimePro;
	
	// Get Map Name from results
	if (SQL_FetchRow(results[0])) {
		SQL_FetchString(results[0], 0, mapName, sizeof(mapName));
	}
	// Get WR info from results
	if (SQL_GetRowCount(results[1]) > 0) {
		mapHasRecord = true;
		if (SQL_FetchRow(results[1])) {
			SQL_FetchString(results[1], 0, recordHolder, sizeof(recordHolder));
			runTime = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[1], 1));
			teleportsUsed = SQL_FetchInt(results[1], 2);
		}
	}
	// Get Pro WR info from results
	if (SQL_GetRowCount(results[2]) > 0) {
		mapHasRecordPro = true;
		if (SQL_FetchRow(results[2])) {
			SQL_FetchString(results[2], 0, recordHolderPro, sizeof(recordHolderPro));
			runTimePro = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[2], 1));
		}
	}
	
	// Print WR header to chat
	if (course == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "WR Header", mapName, gC_StylePhrases[style]);
	}
	else {
		CPrintToChat(client, "%t %t", "KZ Prefix", "WR Header (Bonus)", mapName, course, gC_StylePhrases[style]);
	}
	
	// Print WR times to chat
	if (!mapHasRecord) {
		CPrintToChat(client, "  %t", "WR No Times");
	}
	else if (!mapHasRecordPro) {
		CPrintToChat(client, "  %t", "WR Time - Map", SimpleKZ_FormatTime(runTime), teleportsUsed, recordHolder);
		CPrintToChat(client, "  %t", "WR Time - No Pro Time");
	}
	else if (teleportsUsed == 0) {
		CPrintToChat(client, "  %t", "WR Time - Map (Pro)", SimpleKZ_FormatTime(runTimePro), recordHolderPro);
	}
	else {
		CPrintToChat(client, "  %t", "WR Time - Map", SimpleKZ_FormatTime(runTime), teleportsUsed, recordHolder);
		CPrintToChat(client, "  %t", "WR Time - Pro", SimpleKZ_FormatTime(runTimePro), recordHolderPro);
	}
}

void DB_PrintRecords_FindMap(int client, const char[] mapSearch, int course, KZStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindMap(mapSearch, DB_TxnSuccess_PrintRecords_FindMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintRecords_FindMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char mapSearch[33];
	data.ReadString(mapSearch, sizeof(mapSearch));
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	else if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0])) {  // Result is the MapID
		DB_PrintRecords(client, SQL_FetchInt(results[0], 0), course, style);
	}
}



/*===============================  Map Top Menu  ===============================*/

void DB_OpenMapTop(int client, int mapID, int course, KZStyle style) {
	char query[512];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenMapTop, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTop(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_FetchRow(results[0])) {  // Result is name of map
		SQL_FetchString(results[0], 0, gC_MapTopMapName[client], sizeof(gC_MapTopMapName[]));
		gI_MapTopMapID[client] = mapID;
		gI_MapTopCourse[client] = course;
		g_MapTopStyle[client] = style;
		DisplayMapTopMenu(client);
	}
}

void DB_OpenMapTop_FindMap(int client, const char[] mapSearch, int course, KZStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindMap(mapSearch, DB_TxnSuccess_OpenMapTop_FindMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTop_FindMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char mapSearch[33];
	data.ReadString(mapSearch, sizeof(mapSearch));
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0])) {  // Result is the MapID
		DB_OpenMapTop(client, SQL_FetchInt(results[0], 0), course, style);
	}
}



/*===============================  Map Top Submenu  ===============================*/

void DB_OpenMapTop20(int client, int mapID, int course, KZStyle style, KZTimeType timeType) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	char query[512];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteCell(timeType);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get map name
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	// Get top 20 times for each time type
	switch (timeType) {
		case KZTimeType_Normal:FormatEx(query, sizeof(query), sql_getmaptop, mapID, course, style, 20);
		case KZTimeType_Pro:FormatEx(query, sizeof(query), sql_getmaptoppro, mapID, course, style, 20);
		case KZTimeType_Theoretical:FormatEx(query, sizeof(query), sql_getmaptoptheoretical, mapID, course, style, 20);
	}
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenMapTop20, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTop20(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	KZTimeType timeType = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	// Get map name from results
	char mapName[64];
	if (SQL_FetchRow(results[0])) {
		SQL_FetchString(results[0], 0, mapName, sizeof(mapName));
	}
	// Check if there are any times
	if (SQL_GetRowCount(results[1]) == 0) {
		switch (timeType) {
			case KZTimeType_Normal:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times");
			case KZTimeType_Pro:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times (Pro)");
			case KZTimeType_Theoretical:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times");
		}
		DisplayMapTopMenu(client);
		return;
	}
	
	RemoveAllMenuItems(gH_MapTopSubMenu[client]);
	
	// Set submenu title
	if (course == 0) {
		SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title", client, 
			gC_TimeTypePhrases[timeType], mapName, gC_StylePhrases[style]);
	}
	else {
		SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Bonus)", client, 
			gC_TimeTypePhrases[timeType], mapName, course, gC_StylePhrases[style]);
	}
	
	// Add submenu items
	char newMenuItem[256], playerName[33];
	float runTime;
	int teleports, rank = 0;
	
	while (SQL_FetchRow(results[1])) {
		rank++;
		SQL_FetchString(results[1], 0, playerName, sizeof(playerName));
		runTime = SimpleKZ_TimeIntToFloat(SQL_FetchInt(results[1], 1));
		switch (timeType) {
			case KZTimeType_Normal: {
				teleports = SQL_FetchInt(results[1], 2);
				FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %11s  %d TP      %s", 
					rank, SimpleKZ_FormatTime(runTime), teleports, playerName);
			}
			case KZTimeType_Pro: {
				FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %11s   %s", 
					rank, SimpleKZ_FormatTime(runTime), playerName);
			}
			case KZTimeType_Theoretical: {
				teleports = SQL_FetchInt(results[1], 2);
				FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %11s  %d TP      %s", 
					rank, SimpleKZ_FormatTime(runTime), teleports, playerName);
			}
		}
		AddMenuItem(gH_MapTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_MapTopSubMenu[client], client, MENU_TIME_FOREVER);
}



/*===============================  Player Top  ===============================*/

void DB_OpenPlayerTop20(int client, KZTimeType timeType, KZStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	char query[1024];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(timeType);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get top 20 players
	switch (timeType) {
		case KZTimeType_Normal: {
			FormatEx(query, sizeof(query), sql_gettopplayers_map, style);
			txn.AddQuery(query);
		}
		case KZTimeType_Pro: {
			FormatEx(query, sizeof(query), sql_gettopplayers_pro, style);
			txn.AddQuery(query);
		}
		case KZTimeType_Theoretical: {
			FormatEx(query, sizeof(query), sql_gettopplayers_theoretical, style);
			txn.AddQuery(query);
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenPlayerTop20, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenPlayerTop20(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	KZRecordType timeType = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0) {
		switch (timeType) {
			case KZTimeType_Normal:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times");
			case KZTimeType_Pro:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times (Pro)");
			case KZTimeType_Theoretical:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times");
		}
		DisplayPlayerTopMenu(client);
		return;
	}
	
	RemoveAllMenuItems(gH_PlayerTopSubMenu[client]);
	
	// Set submenu title
	SetMenuTitle(gH_PlayerTopSubMenu[client], "%T", "Player Top Submenu - Title", client, 
		gC_TimeTypePhrases[timeType], gC_StylePhrases[style]);
	
	// Add submenu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results[0])) {
		rank++;
		char playerString[33];
		SQL_FetchString(results[0], 0, playerString, sizeof(playerString));
		FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %s (%d)", rank, playerString, SQL_FetchInt(results[0], 1));
		AddMenuItem(gH_PlayerTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_PlayerTopSubMenu[client], client, MENU_TIME_FOREVER);
}



/*===============================  Percentage Completion  ===============================*/

void DB_GetCompletion(int client, int targetPlayerID, KZStyle style, bool print) {
	if (!gB_ConnectedToDB) {
		if (print) {
			CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		}
		return;
	}
	
	char query[512];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(targetPlayerID);
	data.WriteCell(style);
	data.WriteCell(print);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Alias of PlayerID
	FormatEx(query, sizeof(query), sql_players_getalias, targetPlayerID);
	txn.AddQuery(query);
	// Get total number of ranked maps
	txn.AddQuery(sql_getcounttotalmaps);
	// Get number of map completions
	FormatEx(query, sizeof(query), sql_getcountmapscompleted, targetPlayerID, style);
	txn.AddQuery(query);
	// Get number of map completions (PRO)
	FormatEx(query, sizeof(query), sql_getcountmapscompletedpro, targetPlayerID, style);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_GetCompletion, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_GetCompletion(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int targetPlayerID = data.ReadCell();
	KZStyle style = data.ReadCell();
	bool print = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client or target is no longer valid so don't continue
		return;
	}
	
	char playerName[MAX_NAME_LENGTH];
	int totalMaps, completions, completionsPro;
	
	// Get Player Name from results
	if (SQL_FetchRow(results[0])) {
		SQL_FetchString(results[0], 0, playerName, sizeof(playerName));
	}
	// Get total number of ranked maps from results
	if (SQL_FetchRow(results[1])) {
		totalMaps = SQL_FetchInt(results[1], 0);
	}
	// Get completed maps from results
	if (SQL_FetchRow(results[2])) {
		completions = SQL_FetchInt(results[2], 0);
	}
	// Get completed maps (Pro) from results
	if (SQL_FetchRow(results[3])) {
		completionsPro = SQL_FetchInt(results[3], 0);
	}
	
	// Print completion message to chat if specified
	if (print) {
		if (totalMaps == 0) {
			CPrintToChat(client, "%t %t", "KZ Prefix", "No Ranked Maps");
		}
		else {
			CPrintToChat(client, "%t %t", "KZ Prefix", "Map Completion", playerName, completions, totalMaps, completionsPro, totalMaps, gC_StylePhrases[style]);
		}
	}
	// Set scoreboard MVP stars to percentage PRO completion of default style
	if (totalMaps != 0 && targetPlayerID == SimpleKZ_GetPlayerID(client) && style == SimpleKZ_GetDefaultStyle()) {
		CS_SetMVPCount(client, RoundToFloor(float(completionsPro) / float(totalMaps) * 100.0));
	}
}

void DB_GetCompletion_FindPlayer(int client, const char[] target, KZStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(target);
	data.WriteCell(style);
	
	DB_FindPlayer(target, DB_TxnSuccess_GetCompletion_FindPlayer, data, DBPrio_Low);
}

public void DB_TxnSuccess_GetCompletion_FindPlayer(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char playerSearch[33];
	data.ReadString(playerSearch, sizeof(playerSearch));
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	else if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Player Not Found", playerSearch);
		return;
	}
	else if (SQL_FetchRow(results[0])) {  // Result is the PlayerID
		DB_GetCompletion(client, SQL_FetchInt(results[0], 0), style, true);
	}
} 