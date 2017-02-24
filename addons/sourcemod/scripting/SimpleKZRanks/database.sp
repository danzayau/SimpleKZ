/*	database.sp
	
	Database interaction.
*/


/*===============================  General  ===============================*/

void DB_CreateTables() {
	// Not using transactions because alter queries will return an error e.g. if column already exists
	SQL_LockDatabase(gH_DB);
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			SQL_FastQuery(gH_DB, sql_maps_create);
			SQL_FastQuery(gH_DB, sqlite_times_create);
			SQL_FastQuery(gH_DB, sql_times_alter1); // 0.9.0: Added movement styles
			SQL_FastQuery(gH_DB, sqlite_times_createindex_mapsteamid);
		}
		case DatabaseType_MySQL: {
			SQL_FastQuery(gH_DB, sql_maps_create);
			SQL_FastQuery(gH_DB, mysql_times_create);
			SQL_FastQuery(gH_DB, sql_times_alter1); // 0.9.0: Added movement styles
		}
	}
	SQL_UnlockDatabase(gH_DB);
}

// Error check callback for queries don't return any results
public void DB_Callback_Generic(Handle database, Handle results, const char[] error, int client) {
	if (results == INVALID_HANDLE) {
		SetFailState("%T", "Database_QueryError", LANG_SERVER, error);
	}
}

// Error report callback for failed txns
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("%T", "Database_TransactionError", LANG_SERVER, error);
}



/*===============================  Maps  ===============================*/

void DB_SaveMapInfo() {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			FormatEx(query, sizeof(query), sqlite_maps_insert, 0, gC_CurrentMap);
			SQL_TQuery(gH_DB, DB_Callback_Generic, query, DBPrio_High);
		}
		case DatabaseType_MySQL: {
			FormatEx(query, sizeof(query), mysql_maps_insert, 0, gC_CurrentMap);
			SQL_TQuery(gH_DB, DB_Callback_Generic, query, DBPrio_High);
		}
	}
}

void DB_UpdateMapPool(int client) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	Handle file = OpenFile(MAPPOOL_FILE_PATH, "r");
	if (file == INVALID_HANDLE) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "FileOpen_Fail", MAPPOOL_FILE_PATH);
		return;
	}
	
	Transaction txn = SQL_CreateTransaction();
	char line[33], query[512];
	txn.AddQuery(sql_maps_reset_mappool);
	while (ReadFileLine(file, line, sizeof(line))) {
		TrimString(line);
		if (line[0] == '\0' || line[0] == ';' || (line[0] == '/' && line[1] == '/')) {
			continue;
		}
		String_ToLower(line, line, sizeof(line));
		switch (g_DBType) {
			case DatabaseType_SQLite: {
				// UPDATE OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_update, 1, line);
				txn.AddQuery(query);
				// INSERT OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_insert, 1, line);
				txn.AddQuery(query);
			}
			case DatabaseType_MySQL: {
				FormatEx(query, sizeof(query), mysql_maps_upsert, 1, line);
				txn.AddQuery(query);
			}
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_UpdateMapPool, DB_TxnFailure_Generic, client, DBPrio_Low);
	CloseHandle(file);
}

public void DB_TxnSuccess_UpdateMapPool(Handle db, int client, int numQueries, Handle[] results, any[] queryData) {
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	CPrintToChat(client, "%t %t", "KZ_Tag", "MapPool_UpdateSuccess");
}



/*===============================  End Time Processing  ===============================*/

void DB_ProcessEndTimer(int client, const char[] map, float runTime, int teleportsUsed, float theoreticalTime, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	data.WriteFloat(runTime);
	data.WriteCell(teleportsUsed);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	char query[512];
	// Save runTime to DB
	FormatEx(query, sizeof(query), sql_times_insert, 
		gC_SteamID[client], map, runTime, teleportsUsed, theoreticalTime, style);
	txn.AddQuery(query);
	
	// Get PB
	FormatEx(query, sizeof(query), sql_getpb, map, gC_SteamID[client], style, 2);
	txn.AddQuery(query);
	// Get Rank
	FormatEx(query, sizeof(query), sql_getmaprank, map, gC_SteamID[client], style, map, style);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_getlowestmaprank, map, style);
	txn.AddQuery(query);
	
	if (teleportsUsed == 0) {
		// Get PRO PB
		FormatEx(query, sizeof(query), sql_getpbpro, map, gC_SteamID[client], style, 2);
		txn.AddQuery(query);
		// Get PRO Rank
		FormatEx(query, sizeof(query), sql_getmaprankpro, map, gC_SteamID[client], style, map, style);
		txn.AddQuery(query);
		// Get Number of Players with PRO Times
		FormatEx(query, sizeof(query), sql_getlowestmaprankpro, map, style);
		txn.AddQuery(query);
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_ProcessEndTimer, DB_TxnFailure_Generic, data, DBPrio_Normal);
}

public void DB_TxnSuccess_ProcessEndTimer(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	float runTime = data.ReadFloat();
	int teleportsUsed = data.ReadCell();
	MovementStyle style = data.ReadCell();
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
	else {  // Only 1 row (the time they just got)
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
	
	// New record
	if ((newPB && rank == 1) && !(newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnBeatMapRecord(client, map, RecordType_Map, runTime, style);
	}
	else if (!(newPB && rank == 1) && (newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnBeatMapRecord(client, map, RecordType_Pro, runTime, style);
	}
	else if ((newPB && rank == 1) && (newPBPro && rankPro == 1)) {
		Call_SimpleKZ_OnBeatMapRecord(client, map, RecordType_MapAndPro, runTime, style);
	}
	
	// New PB
	if (newPB) {
		if (firstTime) {
			Call_SimpleKZ_OnBeatMapFirstTime(client, map, RunType_Normal, runTime, rank, maxRank, style);
		}
		else {
			Call_SimpleKZ_OnImproveTime(client, map, RunType_Normal, runTime, improvement, rank, maxRank, style);
		}
	}
	
	// New PRO PB
	if (newPBPro) {
		if (firstTimePro) {
			Call_SimpleKZ_OnBeatMapFirstTime(client, map, RunType_Pro, runTime, rankPro, maxRankPro, style);
		}
		else {
			Call_SimpleKZ_OnImproveTime(client, map, RunType_Pro, runTime, improvementPro, rankPro, maxRankPro, style);
		}
	}
	
	// Update completion percentage in scoreboard
	DB_GetCompletion(client, client, SimpleKZ_GetMovementStyle(client), false);
}



/*===============================  Print Personal Bests  ===============================*/

void DB_PrintPBs(int client, int target, const char[] map, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	// Step 1: Look for map name in database
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(target);
	data.WriteString(map);
	data.WriteCell(style);
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	FormatEx(query, sizeof(query), sql_maps_select_like, mapEscaped, mapEscaped);
	SQL_TQuery(gH_DB, DB_Callback_PrintPBs1, query, data, DBPrio_Low);
	
	gB_HasSeenPBs[client] = true;
}

public void DB_Callback_PrintPBs1(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	int target = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client) || !IsValidClient(target)) {  // Client or target is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results) == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapNotFound", map);
		return;
	}
	
	else if (SQL_FetchRow(results)) {
		// Step 2: Got map name from database - now get PBs		
		SQL_FetchString(results, 0, map, sizeof(map));
		
		data = CreateDataPack();
		data.WriteCell(client);
		data.WriteCell(target);
		data.WriteString(map);
		data.WriteCell(style);
		
		Transaction txn = SQL_CreateTransaction();
		char query[512];
		
		// Get PB
		FormatEx(query, sizeof(query), sql_getpb, map, gC_SteamID[target], style, 1);
		txn.AddQuery(query);
		// Get Rank
		FormatEx(query, sizeof(query), sql_getmaprank, map, gC_SteamID[target], style, map, style);
		txn.AddQuery(query);
		// Get Number of Players with Times
		FormatEx(query, sizeof(query), sql_getlowestmaprank, map, style);
		txn.AddQuery(query);
		
		// Get PRO PB
		FormatEx(query, sizeof(query), sql_getpbpro, map, gC_SteamID[target], style, 1);
		txn.AddQuery(query);
		// Get PRO Rank
		FormatEx(query, sizeof(query), sql_getmaprankpro, map, gC_SteamID[target], style, map, style);
		txn.AddQuery(query);
		// Get Number of Players with PRO Times
		FormatEx(query, sizeof(query), sql_getlowestmaprankpro, map, style);
		txn.AddQuery(query);
		
		SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintPBs2, DB_TxnFailure_Generic, data, DBPrio_Low);
	}
}

public void DB_TxnSuccess_PrintPBs2(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	// Step 3: Print the PB info
	data.Reset();
	int client = data.ReadCell();
	int target = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client) || !IsValidClient(target)) {  // Client or target is no longer valid so don't continue
		return;
	}
	
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
		CPrintToChat(client, "%t %t", "KZ_Tag", "PB_Header_Self", map, gC_StyleChatPhrases[style]);
	}
	else {
		CPrintToChat(client, "%t %t", "KZ_Tag", "PB_Header", map, target, gC_StyleChatPhrases[style]);
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
		if (target == client) {
			CPrintToChat(client, "  %t", "PB_NoTimes_Self");
		}
		else {
			CPrintToChat(client, "  %t", "PB_NoTimes");
		}
	}
	else if (!hasPBPro) {
		CPrintToChat(client, "  %t", "PB_Map", FormatTimeFloat(runTime), rank, maxRank, teleportsUsed, FormatTimeFloat(theoreticalRunTime));
		CPrintToChat(client, "  %t", "PB_Pro_None");
	}
	else if (teleportsUsed == 0) {  // Their MAP PB has 0 teleports, and is therefore also their PRO PB
		CPrintToChat(client, "  %t", "PB_Map_Pro", FormatTimeFloat(runTime), rank, maxRank, rankPro, maxRankPro);
	}
	else {
		CPrintToChat(client, "  %t", "PB_Map", FormatTimeFloat(runTime), rank, maxRank, teleportsUsed, FormatTimeFloat(theoreticalRunTime));
		CPrintToChat(client, "  %t", "PB_Pro", FormatTimeFloat(runTimePro), rankPro, maxRankPro);
	}
}



/*===============================  Print Map Records  ===============================*/

void DB_PrintMapRecords(int client, const char[] map, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	// Step 1: Look for map name in database
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	data.WriteCell(style);
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	FormatEx(query, sizeof(query), sql_maps_select_like, mapEscaped, mapEscaped);
	SQL_TQuery(gH_DB, DB_Callback_PrintMapRecords1, query, data, DBPrio_Low);
}

public void DB_Callback_PrintMapRecords1(Handle db, Handle results, const char[] error, DataPack data) {
	// Step 2: Got map name from database - now get WRs
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results) == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapNotFound", map);
		return;
	}
	
	else if (SQL_FetchRow(results)) {
		SQL_FetchString(results, 0, map, sizeof(map));
		
		data = CreateDataPack();
		data.WriteCell(client);
		data.WriteString(map);
		data.WriteCell(style);
		
		Transaction txn = SQL_CreateTransaction();
		char query[512];
		
		// Get Map WR
		FormatEx(query, sizeof(query), sql_getmaptop, map, style, 1);
		txn.AddQuery(query);
		// Get PRO WR
		FormatEx(query, sizeof(query), sql_getmaptoppro, map, style, 1);
		txn.AddQuery(query);
		
		SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintMapRecords2, DB_TxnFailure_Generic, data, DBPrio_Low);
	}
}

public void DB_TxnSuccess_PrintMapRecords2(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	// Step 3: Print the map records
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	bool hasRecord = false;
	bool hasRecordPro = false;
	
	char recordHolder[33];
	float runTime;
	int teleportsUsed;
	
	char recordHolderPro[33];
	float runTimePro;
	
	CPrintToChat(client, "%t %t", "KZ_Tag", "WR_Header", map, gC_StyleChatPhrases[style]);
	
	// Get WR info from results
	if (SQL_GetRowCount(results[0]) > 0) {
		hasRecord = true;
		
		SQL_FetchRow(results[0]);
		SQL_FetchString(results[0], 0, recordHolder, sizeof(recordHolder));
		runTime = SQL_FetchFloat(results[0], 1);
		teleportsUsed = SQL_FetchInt(results[0], 2);
		
		if (SQL_GetRowCount(results[1]) > 0) {
			hasRecordPro = true;
			
			SQL_FetchRow(results[1]);
			SQL_FetchString(results[1], 0, recordHolderPro, sizeof(recordHolderPro));
			runTimePro = SQL_FetchFloat(results[1], 1);
		}
	}
	
	// Print WR info
	if (!hasRecord) {
		CPrintToChat(client, "  %t", "WR_NoTimes");
	}
	else if (!hasRecordPro) {
		CPrintToChat(client, "  %t", "WR_Map", FormatTimeFloat(runTime), teleportsUsed, recordHolder);
		CPrintToChat(client, "  %t", "WR_Pro_None");
	}
	else if (teleportsUsed == 0) {
		CPrintToChat(client, "  %t", "WR_Map_Pro", FormatTimeFloat(runTimePro), recordHolderPro);
	}
	else {
		CPrintToChat(client, "  %t", "WR_Map", FormatTimeFloat(runTime), teleportsUsed, recordHolder);
		CPrintToChat(client, "  %t", "WR_Pro", FormatTimeFloat(runTimePro), recordHolderPro);
	}
}



/*===============================  Map Top  ===============================*/

void DB_OpenMapTop(int client, const char[] map, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(style);
	
	// Look for map name in database
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	FormatEx(query, sizeof(query), sql_maps_select_like, mapEscaped, mapEscaped);
	SQL_TQuery(gH_DB, DB_Callback_OpenMapTop, query, data, DBPrio_Low);
}

public void DB_Callback_OpenMapTop(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	// Got map name from database - now open maptop menu
	if (SQL_GetRowCount(results) == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapNotFound", gC_MapTopMap[client]);
		return;
	}
	else if (SQL_FetchRow(results)) {
		SQL_FetchString(results, 0, gC_MapTopMap[client], sizeof(gC_MapTopMap[]));
		g_MapTopStyle[client] = style;
		DisplayMapTopMenu(client);
	}
}

void DB_OpenMapTop20(int client, const char[] map, RunType runType, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	data.WriteCell(runType);
	data.WriteCell(style);
	
	char query[512];
	switch (runType) {
		case RunType_Normal:FormatEx(query, sizeof(query), sql_getmaptop, map, style, 20);
		case RunType_Pro:FormatEx(query, sizeof(query), sql_getmaptoppro, map, style, 20);
		case RunType_Theoretical:FormatEx(query, sizeof(query), sql_getmaptoptheoretical, map, style, 20);
	}
	SQL_TQuery(gH_DB, DB_Callback_OpenMapTop20, query, data, DBPrio_Low);
}

public void DB_Callback_OpenMapTop20(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	RunType runType = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results) == 0) {
		switch (runType) {
			case RunType_Normal:CPrintToChat(client, "%t %t", "KZ_Tag", "MapTop_NoTimes", map);
			case RunType_Pro:CPrintToChat(client, "%t %t", "KZ_Tag", "MapTop_NoTimes_Pro", map);
			case RunType_Theoretical:CPrintToChat(client, "%t %t", "KZ_Tag", "MapTop_NoTimes", map);
		}
		DisplayMapTopMenu(client);
		return;
	}
	
	RemoveAllMenuItems(gH_MapTopSubMenu[client]);
	
	switch (runType) {
		case RunType_Normal:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "MapTopMenu_Top20Title", client, map, gC_StyleMenuPhrases[style]);
		case RunType_Pro:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "MapTopMenu_Top20ProTitle", client, map, gC_StyleMenuPhrases[style]);
		case RunType_Theoretical:SetMenuTitle(gH_MapTopSubMenu[client], "%T", "MapTopMenu_Top20TheoreticalTitle", client, map, gC_StyleMenuPhrases[style]);
	}
	
	// Add menu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results)) {
		rank++;
		char playerString[33];
		SQL_FetchString(results, 0, playerString, sizeof(playerString));
		switch (runType) {
			case RunType_Normal: {
				FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s (%d TP)     %s", 
					rank, FormatTimeFloat(SQL_FetchFloat(results, 1)), SQL_FetchInt(results, 2), playerString);
			}
			case RunType_Pro: {
				FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s     %s", 
					rank, FormatTimeFloat(SQL_FetchFloat(results, 1)), playerString);
			}
			case RunType_Theoretical: {
				FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s (%d TP)     %s", 
					rank, FormatTimeFloat(SQL_FetchFloat(results, 1)), SQL_FetchInt(results, 2), playerString);
			}
		}
		AddMenuItem(gH_MapTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_MapTopSubMenu[client], client, MENU_TIME_FOREVER);
}



/*===============================  Percentage Completion  ===============================*/

void DB_GetCompletion(int client, int target, MovementStyle style, bool print) {
	if (!gB_ConnectedToDB) {
		if (print) {
			CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		}
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(target);
	data.WriteCell(style);
	data.WriteCell(view_as<int>(print));
	
	Transaction txn = SQL_CreateTransaction();
	char query[512];
	
	// Get total number of ranked maps
	txn.AddQuery(sql_getcounttotalmaps);
	// Get number of map completions
	FormatEx(query, sizeof(query), sql_getcountmapscompleted, gC_SteamID[target], style);
	txn.AddQuery(query);
	// Get number of map completions (PRO)
	FormatEx(query, sizeof(query), sql_getcountmapscompletedpro, gC_SteamID[target], style);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_GetCompletion, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_GetCompletion(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int target = data.ReadCell();
	MovementStyle style = data.ReadCell();
	bool print = view_as<bool>(data.ReadCell());
	CloseHandle(data);
	
	if (!IsValidClient(client) || !IsValidClient(target)) {  // Client or target is no longer valid so don't continue
		return;
	}
	
	int totalMaps, completions, completionsPro;
	float percentagePro;
	
	if (SQL_FetchRow(results[0])) {
		totalMaps = SQL_FetchInt(results[0], 0);
		if (totalMaps == 0) {
			if (print) {
				CPrintToChat(client, "%t %t", "KZ_Tag", "NoRankedMaps");
			}
			return;
		}
	}
	if (SQL_FetchRow(results[1])) {
		completions = SQL_FetchInt(results[1], 0);
	}
	if (SQL_FetchRow(results[2])) {
		completionsPro = SQL_FetchInt(results[2], 0);
	}
	
	percentagePro = float(completionsPro) / float(totalMaps) * 100.0;
	CS_SetMVPCount(target, RoundToFloor(percentagePro));
	
	if (print) {
		if (target == client) {
			CPrintToChat(client, "%t %t", "KZ_Tag", "MapCompletion_Self", completions, totalMaps, completionsPro, totalMaps, gC_StyleChatPhrases[style]);
		}
		else {
			CPrintToChat(client, "%t %t", "KZ_Tag", "MapCompletion", target, completions, totalMaps, completionsPro, totalMaps, gC_StyleChatPhrases[style]);
		}
	}
}



/*===============================  Player Top  ===============================*/

void DB_PlayerTop20(int client, RunType runType, MovementStyle style) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(runType);
	data.WriteCell(style);
	
	char query[1024];
	switch (runType) {
		case RunType_Normal: {
			FormatEx(query, sizeof(query), sql_gettopplayers, style);
			SQL_TQuery(gH_DB, DB_Callback_PlayerTop20, query, data, DBPrio_Low);
		}
		case RunType_Pro: {
			FormatEx(query, sizeof(query), sql_gettopplayerspro, style);
			SQL_TQuery(gH_DB, DB_Callback_PlayerTop20, query, data, DBPrio_Low);
		}
	}
}

public void DB_Callback_PlayerTop20(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	RecordType runType = data.ReadCell();
	MovementStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client)) {  // Client is no longer valid so don't continue
		return;
	}
	
	if (SQL_GetRowCount(results) == 0) {
		switch (runType) {
			case RunType_Normal:CPrintToChat(client, "%t %t", "KZ_Tag", "PlayerTop_NoTimes");
			case RunType_Pro:CPrintToChat(client, "%t %t", "KZ_Tag", "PlayerTop_NoTimesPro");
		}
		
		DisplayPlayerTopMenu(client);
		return;
	}
	
	switch (runType) {
		case RunType_Normal:SetMenuTitle(gH_PlayerTopSubMenu[client], "%T", "PlayerTopMenu_ListTitle", client, gC_StyleMenuPhrases[style]);
		case RunType_Pro:SetMenuTitle(gH_PlayerTopSubMenu[client], "%T", "PlayerTopMenu_ListTitlePro", client, gC_StyleMenuPhrases[style]);
	}
	
	RemoveAllMenuItems(gH_PlayerTopSubMenu[client]);
	
	// Add menu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results)) {
		rank++;
		char playerString[33];
		SQL_FetchString(results, 0, playerString, sizeof(playerString));
		FormatEx(newMenuItem, sizeof(newMenuItem), "  [%02d] %s (%d)", rank, playerString, SQL_FetchInt(results, 1));
		AddMenuItem(gH_PlayerTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_PlayerTopSubMenu[client], client, MENU_TIME_FOREVER);
} 