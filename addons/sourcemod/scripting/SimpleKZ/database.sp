/*	database.sp
	
	Optional database for SimpleKZ.
*/


/*===============================  General  ===============================*/

void DB_SetupDatabase() {
	if (gB_ConnectedToDB) {
		return;
	}
	
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
	Call_SimpleKZ_OnDatabaseConnect();
	GetClientSteamIDAll(); // Ensures these are set for already connected clients (e.g. on plugin reload)
	UpdateCurrentMap(); // Ensures map variable is set (e.g. on plugin reload)
	DB_CreateTables();
}

void DB_CreateTables() {
	Transaction txn = SQL_CreateTransaction();
	txn.AddQuery(sql_players_create);
	txn.AddQuery(sql_preferences_create);
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