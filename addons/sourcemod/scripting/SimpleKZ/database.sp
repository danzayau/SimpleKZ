/*	database.sp
	
	Database interaction.
*/


/*===============================  General  ===============================*/

void DB_SetupDatabase() {
	if (gB_ConnectedToDB) {
		return;
	}
	
	char error[255];
	gH_DB = SQL_Connect("simplekz", true, error, sizeof(error));
	if (gH_DB == INVALID_HANDLE) {
		PrintToServer("%T", "Database Connection Failed", LANG_SERVER, error);
		return;
	}
	
	char databaseType[8];
	SQL_ReadDriver(gH_DB, databaseType, sizeof(databaseType));
	if (strcmp(databaseType, "sqlite", false) == 0) {
		g_DBType = DatabaseType_SQLite;
	}
	else if (strcmp(databaseType, "mysql", false) == 0) {
		g_DBType = DatabaseType_MySQL;
	}
	else {
		PrintToServer("%T", "Invalid Database Driver", LANG_SERVER);
		return;
	}
	
	gB_ConnectedToDB = true;
	DB_CreateTables();
	
	Call_SimpleKZ_OnDatabaseConnect();
}

void DB_CreateTables() {
	SQL_LockDatabase(gH_DB);
	
	// Create/alter database tables
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			SQL_FastQuery(gH_DB, sqlite_players_create);
			SQL_FastQuery(gH_DB, sqlite_options_create);
			SQL_FastQuery(gH_DB, sqlite_maps_create);
			SQL_FastQuery(gH_DB, sqlite_mapcourses_create);
		}
		case DatabaseType_MySQL: {
			SQL_FastQuery(gH_DB, mysql_players_create);
			SQL_FastQuery(gH_DB, mysql_options_create);
			SQL_FastQuery(gH_DB, mysql_maps_create);
			SQL_FastQuery(gH_DB, mysql_mapcourses_create);
		}
	}
	
	SQL_UnlockDatabase(gH_DB);
}

/* Error report callback for failed transactions */
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("%T", "Database Transaction Error", LANG_SERVER, error);
}



/*===============================  Players  ===============================*/

void DB_SetupClient(int client) {
	// Setup Client Step 1 - Upsert them into Players Table
	
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512], name[MAX_NAME_LENGTH], nameEscaped[MAX_NAME_LENGTH * 2 + 1], steamID[18], clientIP[16], country[45];
	GetClientName(client, name, MAX_NAME_LENGTH);
	SQL_EscapeString(gH_DB, name, nameEscaped, MAX_NAME_LENGTH * 2 + 1);
	GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID), true);
	GetClientIP(client, clientIP, sizeof(clientIP));
	if (!GeoipCountry(clientIP, country, sizeof(country))) {
		country = "Unknown";
	}
	
	Transaction txn = SQL_CreateTransaction();
	
	// Insert/Update player into Players table
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			// UPDATE OR IGNORE
			FormatEx(query, sizeof(query), sqlite_players_update, nameEscaped, country, clientIP, steamID);
			txn.AddQuery(query);
			// INSERT OR IGNORE
			FormatEx(query, sizeof(query), sqlite_players_insert, nameEscaped, country, clientIP, steamID);
			txn.AddQuery(query);
		}
		case DatabaseType_MySQL: {
			// INSERT ... ON DUPLICATE KEY ...
			FormatEx(query, sizeof(query), mysql_players_upsert, nameEscaped, country, clientIP, steamID);
			txn.AddQuery(query);
		}
	}
	// Get PlayerID from SteamID
	FormatEx(query, sizeof(query), sql_players_getplayerid, steamID);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClient, DB_TxnFailure_Generic, client, DBPrio_High);
}

public void DB_TxnSuccess_SetupClient(Handle db, int client, int numQueries, Handle[] results, any[] queryData) {
	if (!IsClientAuthorized(client)) {  // Client is no longer authorised so don't continue
		return;
	}
	
	// Retrieve PlayerID from results
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			if (SQL_FetchRow(results[2])) {
				gI_PlayerID[client] = SQL_FetchInt(results[2], 0);
				Call_SimpleKZ_OnRetrievePlayerID(client);
			}
		}
		case DatabaseType_MySQL: {
			if (SQL_FetchRow(results[1])) {
				gI_PlayerID[client] = SQL_FetchInt(results[1], 0);
				Call_SimpleKZ_OnRetrievePlayerID(client);
			}
		}
	}
	
	// Load options now that PlayerID has been retrieved
	DB_LoadOptions(client);
}



/*===============================  Options  ===============================*/

void DB_LoadOptions(int client) {
	if (!gB_ConnectedToDB) {
		SetDefaultOptions(client);
		return;
	}
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get options for the client's PlayerID
	FormatEx(query, sizeof(query), sql_options_get, gI_PlayerID[client]);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_LoadOptions, DB_TxnFailure_Generic, client, DBPrio_High);
}

public void DB_TxnSuccess_LoadOptions(Handle db, int client, int numQueries, Handle[] results, any[] queryData) {
	if (!IsClientAuthorized(client)) {  // Client is no longer authorised so don't continue
		return;
	}
	
	else if (SQL_GetRowCount(results[0]) == 0) {
		// No options found for that PlayerID, so insert those options and then try reload them again
		char query[512];
		
		Transaction txn = SQL_CreateTransaction();
		
		// Insert options
		FormatEx(query, sizeof(query), sql_options_insert, gI_PlayerID[client], GetConVarInt(gCV_DefaultStyle));
		txn.AddQuery(query);
		
		SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_InsertOptions, DB_TxnFailure_Generic, client, DBPrio_High);
	}
	else if (SQL_FetchRow(results[0])) {
		g_Style[client] = view_as<MovementStyle>(SQL_FetchInt(results[0], 0));
		gB_ShowingTeleportMenu[client] = view_as<bool>(SQL_FetchInt(results[0], 1));
		gB_ShowingInfoPanel[client] = view_as<bool>(SQL_FetchInt(results[0], 2));
		gB_ShowingKeys[client] = view_as<bool>(SQL_FetchInt(results[0], 3));
		gB_ShowingPlayers[client] = view_as<bool>(SQL_FetchInt(results[0], 4));
		gB_ShowingWeapon[client] = view_as<bool>(SQL_FetchInt(results[0], 5));
		gB_AutoRestart[client] = view_as<bool>(SQL_FetchInt(results[0], 6));
		gB_SlayOnEnd[client] = view_as<bool>(SQL_FetchInt(results[0], 7));
		gI_Pistol[client] = SQL_FetchInt(results[0], 8);
		gB_CheckpointMessages[client] = view_as<bool>(SQL_FetchInt(results[0], 9));
		gB_CheckpointSounds[client] = view_as<bool>(SQL_FetchInt(results[0], 10));
		gB_TeleportSounds[client] = view_as<bool>(SQL_FetchInt(results[0], 11));
	}
}

public void DB_TxnSuccess_InsertOptions(Handle db, int client, int numQueries, Handle[] results, any[] queryData) {
	DB_LoadOptions(client);
}

void DB_SaveOptions(int client) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Update options
	FormatEx(query, sizeof(query), 
		sql_options_update, 
		g_Style[client], 
		view_as<int>(gB_ShowingTeleportMenu[client]), 
		view_as<int>(gB_ShowingInfoPanel[client]), 
		view_as<int>(gB_ShowingKeys[client]), 
		view_as<int>(gB_ShowingPlayers[client]), 
		view_as<int>(gB_ShowingWeapon[client]), 
		view_as<int>(gB_AutoRestart[client]), 
		view_as<int>(gB_SlayOnEnd[client]), 
		gI_Pistol[client], 
		view_as<int>(gB_CheckpointMessages[client]), 
		view_as<int>(gB_CheckpointSounds[client]), 
		view_as<int>(gB_TeleportSounds[client]), 
		gI_PlayerID[client]);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic, client, DBPrio_High);
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
			// INSERT ... ON DUPLICATE KEY ...
			FormatEx(query, sizeof(query), mysql_maps_upsert, gC_CurrentMap);
			txn.AddQuery(query);
		}
	}
	// Retrieve mapID of map name
	FormatEx(query, sizeof(query), sql_maps_findid, gC_CurrentMap, gC_CurrentMap);
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
	
	DB_InsertMapCourses();
}

void DB_InsertMapCourses() {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	int entity = -1;
	char tempString[32], query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	while ((entity = FindEntityByClassname(entity, "func_button")) != -1) {
		GetEntPropString(entity, Prop_Data, "m_iName", tempString, sizeof(tempString));
		if (StrEqual("climb_startbutton", tempString, false)) {
			switch (g_DBType) {
				case DatabaseType_SQLite:FormatEx(query, sizeof(query), sqlite_mapcourses_insert, gI_CurrentMapID, 0);
				case DatabaseType_MySQL:FormatEx(query, sizeof(query), mysql_mapcourses_insert, gI_CurrentMapID, 0);
			}
			txn.AddQuery(query);
			PrintToServer("start button");
		}
		else if (MatchRegex(gRE_BonusStartButton, tempString) > 0) {
			GetRegexSubString(gRE_BonusStartButton, 1, tempString, sizeof(tempString));
			int bonus = StringToInt(tempString);
			switch (g_DBType) {
				case DatabaseType_SQLite:FormatEx(query, sizeof(query), sqlite_mapcourses_insert, gI_CurrentMapID, bonus);
				case DatabaseType_MySQL:FormatEx(query, sizeof(query), mysql_mapcourses_insert, gI_CurrentMapID, bonus);
			}
			txn.AddQuery(query);
			PrintToServer("bonus button %d", bonus);
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic, 0, DBPrio_High);
} 