/*	database.sp
	
	Database interaction.
*/


/*===============================  General  ===============================*/

void DB_CreateTables() {
	Transaction txn = SQL_CreateTransaction();
	txn.AddQuery(sql_maps_create);
	switch (g_DBType) {
		case SQLITE: {
			txn.AddQuery(sqlite_times_create);
		}
		case MYSQL: {
			txn.AddQuery(mysql_times_create);
		}
	}
	txn.AddQuery(sql_times_createindex_mapsteamid);
	SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic);
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
		case SQLITE: {
			FormatEx(query, sizeof(query), sqlite_maps_insert, 0, gC_CurrentMap);
			SQL_TQuery(gH_DB, DB_Callback_Generic, query);
		}
		case MYSQL: {
			FormatEx(query, sizeof(query), mysql_maps_insert, 0, gC_CurrentMap);
			SQL_TQuery(gH_DB, DB_Callback_Generic, query);
		}
	}
}

void DB_UpdateMapPool(int client) {
	Handle file = OpenFile(MAPPOOL_FILE_PATH, "r");
	if (file == INVALID_HANDLE) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "FileOpen_Fail", MAPPOOL_FILE_PATH);
		return;
	}
	
	Transaction txn = SQL_CreateTransaction();
	char line[33], query[512];
	txn.AddQuery(sql_maps_reset_mappool);
	while (ReadFileLine(file, line, sizeof(line))) {
		if (line[0] == '\0' || line[0] == '/') {
			continue;
		}
		switch (g_DBType) {
			case SQLITE: {
				// UPDATE OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_update, 1, line);
				txn.AddQuery(query);
				// INSERT OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_insert, 1, line);
				txn.AddQuery(query);
			}
			case MYSQL: {
				FormatEx(query, sizeof(query), mysql_maps_upsert, 1, line);
				txn.AddQuery(query);
			}
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_UpdateMapPool, DB_TxnFailure_Generic, client, DBPrio_Low);
	CloseHandle(file);
}

public void DB_TxnSuccess_UpdateMapPool(Handle db, int client, int numQueries, Handle[] results, any[] queryData) {
	CPrintToChat(client, "%t %t", "KZ_Tag", "MapPool_UpdateSuccess");
}



/*===============================  End Time Processing  ===============================*/

void DB_ProcessEndTimer(int client, const char[] map, float runTime, int teleportsUsed, float theoreticalTime) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	data.WriteFloat(runTime);
	data.WriteCell(teleportsUsed);
	
	Transaction txn = SQL_CreateTransaction();
	char query[512];
	// Save runTime to DB
	FormatEx(query, sizeof(query), sql_times_insert, 
		gC_SteamID[client], map, runTime, teleportsUsed, theoreticalTime);
	txn.AddQuery(query);
	// Get MAP record information
	FormatEx(query, sizeof(query), sql_times_gettop, map, 1);
	txn.AddQuery(query);
	// Get PRO record information
	if (teleportsUsed == 0) {
		FormatEx(query, sizeof(query), sql_times_gettoppro, map, 1);
		txn.AddQuery(query);
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_ProcessEndTimer, DB_TxnFailure_Generic, data);
}

public void DB_TxnSuccess_ProcessEndTimer(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	float runTime = data.ReadFloat();
	int teleportsUsed = data.ReadCell();
	CloseHandle(data);
	
	bool newRecord = false;
	bool newRecordPro = false;
	
	SQL_FetchRow(results[1]);
	if (runTime == SQL_FetchFloat(results[1], 1)) {
		newRecord = true;
	}
	if (teleportsUsed == 0) {
		SQL_FetchRow(results[2]);
		if (runTime == SQL_FetchFloat(results[2], 1)) {
			newRecordPro = true;
		}
	}
	
	if (newRecord || newRecordPro) {
		if (newRecord) {
			if (!newRecordPro) {
				Call_SimpleKZ_OnSetRecord(client, map, MAP_RECORD, runTime);
			}
			else {
				Call_SimpleKZ_OnSetRecord(client, map, MAP_AND_PRO_RECORD, runTime);
			}
		}
		else {
			Call_SimpleKZ_OnSetRecord(client, map, PRO_RECORD, runTime);
		}
	}
}



/*===============================  Print Personal Bests  ===============================*/

void DB_PrintPBs(int client, int target, const char[] map) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	// Step 1: Look for map name in database
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(target);
	data.WriteString(map);
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	FormatEx(query, sizeof(query), sql_maps_select_like, mapEscaped, mapEscaped);
	SQL_TQuery(gH_DB, DB_Callback_PrintPBs, query, data);
}

public void DB_Callback_PrintPBs(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	int target = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
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
		
		// Get PRO PB
		FormatEx(query, sizeof(query), sql_times_getpbpro, gC_SteamID[target], map);
		txn.AddQuery(query);
		// Get PRO Rank
		FormatEx(query, sizeof(query), sql_times_getrankpro, gC_SteamID[target], map, map);
		txn.AddQuery(query);
		// Get Number of Players with PRO Times
		FormatEx(query, sizeof(query), sql_times_getcompletionspro, map);
		txn.AddQuery(query);
		
		SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintPBs, DB_TxnFailure_Generic, data);
	}
}

public void DB_TxnSuccess_PrintPBs(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	// Step 3: Print the PB info
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
		CPrintToChat(client, "%t %t", "KZ_Tag", "PB_Header_Self", map);
	}
	else {
		CPrintToChat(client, "%t %t", "KZ_Tag", "PB_Header", map, target);
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
	else if (teleportsUsed == 0) {
		CPrintToChat(client, "  %t", "PB_Map_Pro", FormatTimeFloat(runTime), rank, maxRank, rankPro, maxRankPro);
	}
	else {
		CPrintToChat(client, "  %t", "PB_Map", FormatTimeFloat(runTime), rank, maxRank, teleportsUsed, FormatTimeFloat(theoreticalRunTime));
		CPrintToChat(client, "  %t", "PB_Pro", FormatTimeFloat(runTimePro), rankPro, maxRankPro);
	}
}



/*===============================  Print Map Records  ===============================*/

void DB_PrintMapRecords(int client, const char[] map) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	// Step 1: Look for map name in database
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	FormatEx(query, sizeof(query), sql_maps_select_like, mapEscaped, mapEscaped);
	SQL_TQuery(gH_DB, DB_Callback_PrintMapRecords, query, data);
}

public void DB_Callback_PrintMapRecords(Handle db, Handle results, const char[] error, DataPack data) {
	// Step 2: Got map name from database - now get WRs
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
	if (SQL_GetRowCount(results) == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapNotFound", map);
		return;
	}
	
	else if (SQL_FetchRow(results)) {
		SQL_FetchString(results, 0, map, sizeof(map));
		
		data = CreateDataPack();
		data.WriteCell(client);
		data.WriteString(map);
		
		Transaction txn = SQL_CreateTransaction();
		char query[512];
		
		// Get Map WR
		FormatEx(query, sizeof(query), sql_times_gettop, map, 1);
		txn.AddQuery(query);
		// Get PRO WR
		FormatEx(query, sizeof(query), sql_times_gettoppro, map, 1);
		txn.AddQuery(query);
		
		SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintMapRecords, DB_TxnFailure_Generic, data);
	}
}

public void DB_TxnSuccess_PrintMapRecords(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	// Step 3: Print the map records
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
	
	CPrintToChat(client, "%t %t", "KZ_Tag", "WR_Header", map);
	
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

void DB_OpenMapTop(int client, const char[] map) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	char query[512], mapEscaped[129];
	SQL_EscapeString(gH_DB, map, mapEscaped, sizeof(mapEscaped));
	FormatEx(query, sizeof(query), sql_maps_select_like, mapEscaped, mapEscaped);
	SQL_TQuery(gH_DB, DB_Callback_OpenMapTop, query, client);
}

public void DB_Callback_OpenMapTop(Handle db, Handle results, const char[] error, int client) {
	if (SQL_GetRowCount(results) == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapNotFound", gC_MapTopMap[client]);
		return;
	}
	else if (SQL_FetchRow(results)) {
		SQL_FetchString(results, 0, gC_MapTopMap[client], sizeof(gC_MapTopMap[]));
		DisplayMapTopMenu(client);
	}
}

void DB_OpenTop20(int client, const char[] map) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	
	char query[512];
	FormatEx(query, sizeof(query), sql_times_gettop, map, 20);
	SQL_TQuery(gH_DB, DB_Callback_OpenTop20, query, data);
}

public void DB_Callback_OpenTop20(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
	if (SQL_GetRowCount(results) == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapTop_NoTimes", map);
		DisplayMapTopMenu(client);
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

void DB_OpenTop20Pro(int client, const char[] map) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
		return;
	}
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(map);
	
	char query[512];
	FormatEx(query, sizeof(query), sql_times_gettoppro, map, 20);
	SQL_TQuery(gH_DB, DB_Callback_OpenTop20Pro, query, data);
}

public void DB_Callback_OpenTop20Pro(Handle db, Handle results, const char[] error, DataPack data) {
	data.Reset();
	int client = data.ReadCell();
	char map[33];
	data.ReadString(map, sizeof(map));
	CloseHandle(data);
	
	if (SQL_GetRowCount(results) == 0) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapTop_NoTimes_Pro", map);
		DisplayMapTopMenu(client);
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