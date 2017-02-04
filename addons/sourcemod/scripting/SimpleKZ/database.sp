/*	database.sp
	
	Optional database for SimpleKZ.
*/


/*===============================  General  ===============================*/

void DB_SetupDatabase() {
	char error[255];
	gH_DB = SQL_Connect("simplekz", true, error, sizeof(error));
	if (gH_DB == INVALID_HANDLE) {
		PrintToServer("%T", "Database_ConnectionFailed", LANG_SERVER, error);
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
		PrintToServer("%T", "Database_InvalidDriver", LANG_SERVER);
		return;
	}
	
	gB_ConnectedToDB = true;
	GetClientSteamIDAll(); // Ensures these are set for already connected clients (e.g. on plugin reload)
	UpdateCurrentMap(); // Ensures map variable is set (e.g. on plugin reload)
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
		SetFailState("%T", "Database_QueryError", LANG_SERVER, error);
	}
}

// Error report callback for failed txns
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("%T", "Database_TransactionError", LANG_SERVER, error);
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
		gB_AutoRestart[client] = view_as<bool>(SQL_FetchInt(results, 5));
		int pistolNumber = SQL_FetchInt(results, 6);
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
		BoolToInt(gB_AutoRestart[client]), 
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
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteFloat(gF_CurrentTime[client]);
	data.WriteCell(gI_TeleportsUsed[client]);
	
	Transaction txn = SQL_CreateTransaction();
	char query[512];
	// Save time to DB
	FormatEx(query, sizeof(query), sql_times_insert, 
		gC_SteamID[client], gC_CurrentMap, gF_CurrentTime[client], gI_TeleportsUsed[client], (gF_CurrentTime[client] - gF_WastedTime[client]));
	txn.AddQuery(query);
	// Get Map WR
	FormatEx(query, sizeof(query), sql_times_gettop, gC_CurrentMap, 1);
	txn.AddQuery(query);
	// Get PRO WR
	if (gI_TeleportsUsed[client] == 0) {
		FormatEx(query, sizeof(query), sql_times_gettoppro, gC_CurrentMap, 1);
		txn.AddQuery(query);
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_ProcessEndTimer, DB_TxnFailure_Generic, data);
}

public void DB_TxnSuccess_ProcessEndTimer(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	float runTime = data.ReadFloat();
	int teleportsUsed = data.ReadCell();
	CloseHandle(data);
	
	bool newRecord = false;
	bool newRecordPro = false;
	
	SQL_FetchRow(results[1]);
	if (runTime == SQL_FetchFloat(results[1], 1)) {
		newRecord = true;
	}
	if (gI_TeleportsUsed[client] == 0) {
		SQL_FetchRow(results[2]);
		if (teleportsUsed == 0 && runTime == SQL_FetchFloat(results[2], 1)) {
			newRecordPro = true;
		}
	}
	
	if (newRecord || newRecordPro) {
		if (newRecord) {
			if (!newRecordPro) {  // Only new MAP Record
				CPrintToChatAll("%t %t", "KZ_Tag", "BeatMapRecord", client);
				EmitSoundToAll("*/commander/commander_comment_01.wav");
			}
			else {  // and PRO Record
				CPrintToChatAll("%t %t", "KZ_Tag", "BeatMapAndProRecord", client);
				EmitSoundToAll("*/commander/commander_comment_05.wav");
			}
		}
		else {  // Only new PRO Record
			CPrintToChatAll("%t %t", "KZ_Tag", "BeatProRecord", client);
			EmitSoundToAll("*/commander/commander_comment_02.wav");
		}
	}
}



/*===============================  Print Personal Bests  ===============================*/

void DB_PrintPBs(int client, int target, const char[] map) {
	if (!gB_ConnectedToDB) {
		CPrintToChat(client, "%t %t", "KZ_Tag", "Database_NotConnected");
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
	
	DataPack data = CreateDataPack();
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
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapTop_None", map);
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
		CPrintToChat(client, "%t %t", "KZ_Tag", "MapTop_Pro_None", map);
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