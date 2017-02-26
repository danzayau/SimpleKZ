/*	database.sp
	
	Database interaction.
*/


/*===============================  General  ===============================*/

void DB_CreateTables() {
	Transaction txn = SQL_CreateTransaction();
	
	// Create database tables
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			txn.AddQuery(sqlite_maps_create);
			txn.AddQuery(sqlite_times_create);
		}
		case DatabaseType_MySQL: {
			txn.AddQuery(mysql_maps_create);
			txn.AddQuery(mysql_times_create);
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic, 0, DBPrio_High);
}

// Error report callback for failed txns
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("%T", "Database Transaction Error", LANG_SERVER, error);
}



/*===============================  Maps  ===============================*/

void DB_SetupMap() {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Insert/Update map into database
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			// UPDATE OR IGNORE
			FormatEx(query, sizeof(query), sqlite_maps_update, gC_CurrentMap);
			txn.AddQuery(query);
			// INSERT OR IGNORE
			FormatEx(query, sizeof(query), sqlite_maps_insert, gC_CurrentMap);
			txn.AddQuery(query);
		}
		case DatabaseType_MySQL: {
			FormatEx(query, sizeof(query), mysql_maps_upsert, gC_CurrentMap);
			txn.AddQuery(query);
		}
	}
	// Retrieve mapID of map name
	FormatEx(query, sizeof(query), sql_maps_getmapid, gC_CurrentMap, gC_CurrentMap);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupMap, DB_TxnFailure_Generic, 0, DBPrio_High);
}

public void DB_TxnSuccess_SetupMap(Handle db, any data, int numQueries, Handle[] results, any[] queryData) {
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			if (SQL_FetchRow(results[2])) {
				gI_CurrentMapID = SQL_FetchInt(results[2], 0);
				Call_SimpleKZ_OnRetrieveCurrentMapID();
			}
		}
		case DatabaseType_MySQL: {
			if (SQL_FetchRow(results[1])) {
				gI_CurrentMapID = SQL_FetchInt(results[1], 0);
				Call_SimpleKZ_OnRetrieveCurrentMapID();
			}
		}
	}
}

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
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	CPrintToChat(client, "%t %t", "KZ Prefix", "Map Pool Update Successful");
}



/*===============================  End Time Processing  ===============================*/

void DB_ProcessTimerEnd(int client, MovementStyle style, int course, float runTime, int teleportsUsed, float theoreticalTime) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(gI_CurrentMapID);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteFloat(runTime);
	data.WriteCell(teleportsUsed);
	
	char query[512];
	int playerID = SimpleKZ_GetPlayerID(client);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Save runTime to DB
	FormatEx(query, sizeof(query), sql_times_insert, playerID, gI_CurrentMapID, course, style, runTime, teleportsUsed, theoreticalTime);
	txn.AddQuery(query);
	
	// Get Top 2 PBs
	FormatEx(query, sizeof(query), sql_getpb, playerID, gI_CurrentMapID, course, style, 2);
	txn.AddQuery(query);
	// Get Rank
	FormatEx(query, sizeof(query), sql_getmaprank, playerID, gI_CurrentMapID, course, style, gI_CurrentMapID, course, style);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_getlowestmaprank, gI_CurrentMapID, course, style);
	txn.AddQuery(query);
	
	if (teleportsUsed == 0) {
		// Get Top 2 PRO PBs
		FormatEx(query, sizeof(query), sql_getpbpro, playerID, gI_CurrentMapID, course, style, 2);
		txn.AddQuery(query);
		// Get PRO Rank
		FormatEx(query, sizeof(query), sql_getmaprankpro, playerID, gI_CurrentMapID, course, style, gI_CurrentMapID, course, style);
		txn.AddQuery(query);
		// Get Number of Players with PRO Times
		FormatEx(query, sizeof(query), sql_getlowestmaprankpro, gI_CurrentMapID, course, style);
		txn.AddQuery(query);
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_ProcessTimerEnd, DB_TxnFailure_Generic, data, DBPrio_Normal);
}

public void DB_TxnSuccess_ProcessTimerEnd(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	MovementStyle style = data.ReadCell();
	float runTime = data.ReadFloat();
	int teleportsUsed = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	bool newPB = false;
	bool firstTime = false;
	float improvement;
	int rank;
	int maxRank;
	
	// Check for new PB
	if (SQL_GetRowCount(results[1]) == 2) {
		SQL_FetchRow(results[1]);
		if (FloatAbs(runTime - SQL_FetchFloat(results[1], 0)) <= 0.0001) {
			newPB = true;
			SQL_FetchRow(results[1]);
			improvement = SQL_FetchFloat(results[1], 0) - runTime;
		}
	}
	else {  // Only 1 row (the time they just got) so this is their first time
		newPB = true;
		firstTime = true;
	}
	
	// If new PB, get rank information
	if (newPB) {
		SQL_FetchRow(results[2]);
		rank = SQL_FetchInt(results[2], 0);
		SQL_FetchRow(results[3]);
		maxRank = SQL_FetchInt(results[3], 0);
	}
	
	bool newPBPro = false;
	bool firstTimePro = false;
	float improvementPro;
	int rankPro;
	int maxRankPro;
	
	// Repeat for PRO runs if necessary
	if (teleportsUsed == 0) {
		// Check for new PRO PB
		if (SQL_GetRowCount(results[4]) == 2) {
			SQL_FetchRow(results[4]);
			if (FloatAbs(runTime - SQL_FetchFloat(results[4], 0)) <= 0.0001) {
				newPBPro = true;
				SQL_FetchRow(results[4]);
				improvementPro = SQL_FetchFloat(results[4], 0) - runTime;
			}
		}
		else {  // Only 1 row (the time they just got)
			newPBPro = true;
			firstTimePro = true;
		}
		// If new PB, get rank information
		if (newPBPro) {
			SQL_FetchRow(results[5]);
			rankPro = SQL_FetchInt(results[5], 0);
			SQL_FetchRow(results[6]);
			maxRankPro = SQL_FetchInt(results[6], 0);
		}
	}
	
	// Call OnNewPersonalBest forward (RunType_Normal)
	if (newPB) {
		if (firstTime) {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, RunType_Normal, true, runTime, -1.0, rank, maxRank);
		}
		else {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, RunType_Normal, false, runTime, improvement, rank, maxRank);
		}
	}
	// Call OnNewPersonalBest forward (RunType_Pro)
	if (newPBPro) {
		if (firstTimePro) {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, RunType_Pro, true, runTime, -1.0, rankPro, maxRankPro);
		}
		else {
			Call_SimpleKZ_OnNewPersonalBest(client, mapID, course, style, RunType_Pro, false, runTime, improvementPro, rankPro, maxRankPro);
		}
	}
	
	// Call OnNewRecord forward
	if ((newPB && rank == 1) && !(newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnNewRecord(client, mapID, course, style, RecordType_Map, runTime);
	}
	else if (!(newPB && rank == 1) && (newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnNewRecord(client, mapID, course, style, RecordType_Pro, runTime);
	}
	else if ((newPB && rank == 1) && (newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnNewRecord(client, mapID, course, style, RecordType_MapAndPro, runTime);
	}
	
	// Update PRO Completion [Standard] percentage in scoreboard
	if (style == MovementStyle_Standard && course == 0 && firstTimePro) {
		DB_GetCompletion(client, client, MovementStyle_Standard, false);
	}
}



/*===============================  Print Personal Bests  ===============================*/

void DB_PrintPBs_SearchMap(int client, int target, const char[] map, int course, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(target);
	data.WriteString(map);
	data.WriteCell(course);
	data.WriteCell(style);
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	
	Transaction txn = SQL_CreateTransaction();
	
	// Look for map name and retrieve it's MapID
	FormatEx(query, sizeof(query), sql_maps_getmapid, mapEscaped, mapEscaped);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintPBs_SearchMap, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintPBs_SearchMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int target = data.ReadCell();
	char searchString[33];
	data.ReadString(searchString, sizeof(searchString));
	int course = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	// Client or target is no longer valid so don't continue
	if (!IsValidClient(client) || !IsValidClient(target)) {
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", searchString);
		return;
	}
	else if (SQL_FetchRow(results[0])) {  // Result is the MapID
		DB_PrintPBs(client, target, SQL_FetchInt(results[0], 0), course, style);
	}
}

void DB_PrintPBs(int client, int target, int mapID, int course, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(target);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	
	int targetPlayerID = SimpleKZ_GetPlayerID(target);
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getmapname, mapID);
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
	int target = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	// Client, target or mapID is no longer valid so don't continue
	if (!IsValidClient(client) || !IsValidClient(target) || mapID != gI_CurrentMapID) {
		return;
	}
	
	char mapName[33];
	
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
	
	// Get Map Name from results
	if (SQL_FetchRow(results[0])) {
		SQL_FetchString(results[0], 0, mapName, sizeof(mapName));
	}
	// Get PB info from results
	if (SQL_GetRowCount(results[1]) > 0) {
		hasPB = true;
		if (SQL_FetchRow(results[1])) {
			runTime = SQL_FetchFloat(results[1], 0);
			teleportsUsed = SQL_FetchInt(results[1], 1);
			theoreticalRunTime = SQL_FetchFloat(results[1], 2);
		}
		if (SQL_FetchRow(results[2])) {
			rank = SQL_FetchInt(results[2], 0);
		}
		if (SQL_FetchRow(results[3])) {
			maxRank = SQL_FetchInt(results[3], 0);
		}
	}
	// Get PB info (Pro) from results
	if (SQL_GetRowCount(results[4]) > 0) {
		hasPBPro = true;
		if (SQL_FetchRow(results[4])) {
			runTimePro = SQL_FetchFloat(results[4], 0);
		}
		if (SQL_FetchRow(results[5])) {
			rankPro = SQL_FetchInt(results[5], 0);
		}
		if (SQL_FetchRow(results[6])) {
			maxRankPro = SQL_FetchInt(results[6], 0);
		}
	}
	
	// Print PB header to chat
	if (course == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "PB Header", target, mapName, gC_StyleChatPhrases[style]);
	}
	else {
		CPrintToChat(client, "%t %t", "KZ Prefix", "PB Header (Bonus)", target, mapName, course, gC_StyleChatPhrases[style]);
	}
	
	// Print PB times to chat
	if (!hasPB) {
		if (target == client) {
			CPrintToChat(client, "  %t", "PB No Times (Self)");
		}
		else {
			CPrintToChat(client, "  %t", "PB No Times");
		}
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



/*===============================  Print Records  ===============================*/

void DB_PrintRecords_SearchMap(int client, const char[] map, int course, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	data.WriteCell(course);
	data.WriteCell(style);
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	
	Transaction txn = SQL_CreateTransaction();
	
	// Look for map name in database and retrieve it's MapID
	FormatEx(query, sizeof(query), sql_maps_getmapid, mapEscaped, mapEscaped);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintRecords_SearchMap, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintRecords_SearchMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char searchString[33];
	data.ReadString(searchString, sizeof(searchString));
	int course = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	else if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", searchString);
		return;
	}
	else if (SQL_FetchRow(results[0])) {  // Result is the MapID
		DB_PrintRecords(client, SQL_FetchInt(results[0], 0), course, style);
	}
}

void DB_PrintRecords(int client, int mapID, int course, MovementStyle style) {
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getmapname, mapID);
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
	MovementStyle style = data.ReadCell();
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
			runTime = SQL_FetchFloat(results[1], 1);
			teleportsUsed = SQL_FetchInt(results[1], 2);
		}
	}
	// Get Pro WR info from results
	if (SQL_GetRowCount(results[2]) > 0) {
		mapHasRecordPro = true;
		if (SQL_FetchRow(results[2])) {
			SQL_FetchString(results[2], 0, recordHolderPro, sizeof(recordHolderPro));
			runTimePro = SQL_FetchFloat(results[2], 1);
		}
	}
	
	// Print WR header to chat
	if (course == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "WR Header", mapName, gC_StyleChatPhrases[style]);
	}
	else {
		CPrintToChat(client, "%t %t", "KZ Prefix", "WR Header (Bonus)", mapName, course, gC_StyleChatPhrases[style]);
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



/*===============================  Map Top  ===============================*/

void DB_OpenMapTop_SearchMap(int client, const char[] map, int course, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	data.WriteCell(course);
	data.WriteCell(style);
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	
	Transaction txn = SQL_CreateTransaction();
	
	// Look for map name in database
	FormatEx(query, sizeof(query), sql_maps_getmapid, mapEscaped, mapEscaped);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenMapTop_SearchMap, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTop_SearchMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char searchString[33];
	data.ReadString(searchString, sizeof(searchString));
	int course = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", searchString);
		return;
	}
	else if (SQL_FetchRow(results[0])) {  // Result is the MapID
		DB_OpenMapTop(client, SQL_FetchInt(results[0], 0), course, style);
	}
}

void DB_OpenMapTop(int client, int mapID, int course, MovementStyle style) {
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getmapname, mapID);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenMapTop, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTop(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	MovementStyle style = data.ReadCell();
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

void DB_OpenMapTop20(int client, int mapID, int course, MovementStyle style, RunType runType) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteCell(runType);
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get map name
	FormatEx(query, sizeof(query), sql_maps_getmapname, mapID);
	txn.AddQuery(query);
	// Get top 20 times for each run type
	switch (runType) {
		case RunType_Normal:FormatEx(query, sizeof(query), sql_getmaptop, mapID, course, style, 20);
		case RunType_Pro:FormatEx(query, sizeof(query), sql_getmaptoppro, mapID, course, style, 20);
		case RunType_Theoretical:FormatEx(query, sizeof(query), sql_getmaptoptheoretical, mapID, course, style, 20);
	}
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenMapTop20, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTop20(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int course = data.ReadCell();
	MovementStyle style = data.ReadCell();
	RunType runType = data.ReadCell();
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
		switch (runType) {
			case RunType_Normal:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times");
			case RunType_Pro:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times (Pro)");
			case RunType_Theoretical:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times");
		}
		DisplayMapTopMenu(client);
		return;
	}
	
	RemoveAllMenuItems(gH_MapTopSubMenu[client]);
	
	// Set submenu title
	if (course == 0) {
		switch (runType) {
			case RunType_Normal:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Top 20)", client, mapName, gC_StyleMenuPhrases[style]);
			case RunType_Pro:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Top 20 Pro)", client, mapName, gC_StyleMenuPhrases[style]);
			case RunType_Theoretical:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Top 20 Theoretical)", client, mapName, gC_StyleMenuPhrases[style]);
		}
	}
	else {
		switch (runType) {
			case RunType_Normal:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Bonus Top 20)", client, mapName, course, gC_StyleMenuPhrases[style]);
			case RunType_Pro:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Bonus Top 20 Pro)", client, mapName, course, gC_StyleMenuPhrases[style]);
			case RunType_Theoretical:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Bonus Top 20 Theoretical)", client, mapName, course, gC_StyleMenuPhrases[style]);
		}
	}
	
	// Add submenu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results[1])) {
		rank++;
		char playerName[33];
		SQL_FetchString(results[1], 0, playerName, sizeof(playerName));
		switch (runType) {
			case RunType_Normal: {
				FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s (%d TP)     %s", 
					rank, SimpleKZ_FormatTime(SQL_FetchFloat(results[1], 1)), SQL_FetchInt(results[1], 2), playerName);
			}
			case RunType_Pro: {
				FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s     %s", 
					rank, SimpleKZ_FormatTime(SQL_FetchFloat(results[1], 1)), playerName);
			}
			case RunType_Theoretical: {
				FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s (%d TP)     %s", 
					rank, SimpleKZ_FormatTime(SQL_FetchFloat(results[1], 1)), SQL_FetchInt(results[1], 2), playerName);
			}
		}
		AddMenuItem(gH_MapTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_MapTopSubMenu[client], client, MENU_TIME_FOREVER);
}



/*===============================  Player Top  ===============================*/

void DB_OpenPlayerTop20(int client, RunType runType, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(runType);
	data.WriteCell(style);
	
	char query[1024];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get top 20 players
	switch (runType) {
		case RunType_Normal: {
			FormatEx(query, sizeof(query), sql_gettopplayers, style);
			txn.AddQuery(query);
		}
		case RunType_Pro: {
			FormatEx(query, sizeof(query), sql_gettopplayerspro, style);
			txn.AddQuery(query);
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenPlayerTop20, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenPlayerTop20(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	RecordType runType = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0) {
		switch (runType) {
			case RunType_Normal:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times");
			case RunType_Pro:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times (Pro)");
		}
		DisplayPlayerTopMenu(client);
		return;
	}
	
	RemoveAllMenuItems(gH_PlayerTopSubMenu[client]);
	
	// Set submenu title
	switch (runType) {
		case RunType_Normal:SetMenuTitle(gH_PlayerTopSubMenu[client], "%T", "Player Top Submenu - Title (Top 20)", client, gC_StyleMenuPhrases[style]);
		case RunType_Pro:SetMenuTitle(gH_PlayerTopSubMenu[client], "%T", "Player Top Submenu - Title (Top 20 Pro)", client, gC_StyleMenuPhrases[style]);
	}
	
	// Add submenu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results[0])) {
		rank++;
		char playerString[33];
		SQL_FetchString(results[0], 0, playerString, sizeof(playerString));
		FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s (%d)", rank, playerString, SQL_FetchInt(results[0], 1));
		AddMenuItem(gH_PlayerTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_PlayerTopSubMenu[client], client, MENU_TIME_FOREVER);
}



/*===============================  Percentage Completion  ===============================*/

void DB_GetCompletion(int client, int target, MovementStyle style, bool print) {
	if (!gB_ConnectedToDB) {
		if (print) {
			CPrintToChat(client, "%t %t", "KZ Prefix", "Database Not Connected");
		}
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(target);
	data.WriteCell(style);
	data.WriteCell(print);
	
	char query[512];
	int targetPlayerID = SimpleKZ_GetPlayerID(target);
	
	Transaction txn = SQL_CreateTransaction();
	
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
	int target = data.ReadCell();
	MovementStyle style = data.ReadCell();
	bool print = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client) || !IsValidClient(target)) {  // Client or target is no longer valid so don't continue
		return;
	}
	
	int totalMaps, completions, completionsPro;
	
	// Get total number of ranked maps from results
	if (SQL_FetchRow(results[0])) {
		totalMaps = SQL_FetchInt(results[0], 0);
	}
	// Get completed maps from results
	if (SQL_FetchRow(results[1])) {
		completions = SQL_FetchInt(results[1], 0);
	}
	// Get completed maps (Pro) from results
	if (SQL_FetchRow(results[2])) {
		completionsPro = SQL_FetchInt(results[2], 0);
	}
	
	// Print completion message to chat if specified
	if (print) {
		if (totalMaps == 0) {
			CPrintToChat(client, "%t %t", "KZ Prefix", "No Ranked Maps");
		}
		else {
			CPrintToChat(client, "%t %t", "KZ Prefix", "Map Completion", target, completions, totalMaps, completionsPro, totalMaps, gC_StyleChatPhrases[style]);
		}
	}
	// Set scoreboard MVP stars to percentage PRO completion of default style
	if (style == SimpleKZ_GetDefaultStyle()) {
		CS_SetMVPCount(target, RoundToFloor(float(completionsPro) / float(totalMaps) * 100.0));
	}
} 