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
			SQL_FastQuery(gH_DB, sqlite_times_create);
		}
		case DatabaseType_MySQL: {
			SQL_FastQuery(gH_DB, mysql_players_create);
			SQL_FastQuery(gH_DB, mysql_options_create);
			SQL_FastQuery(gH_DB, mysql_maps_create);
			SQL_FastQuery(gH_DB, mysql_times_create);
		}
	}
	
	SQL_UnlockDatabase(gH_DB);
}

/* Error report callback for failed transactions */
public void DB_TxnFailure_Generic(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("%T", "Database Transaction Error", LANG_SERVER, error);
}



/*===============================  Players  ===============================*/

void DB_SetupClient(KZPlayer player) {
	// Setup Client Step 1 - Upsert them into Players Table
	
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512], name[MAX_NAME_LENGTH], nameEscaped[MAX_NAME_LENGTH * 2 + 1], steamID[18], clientIP[16], country[45];
	GetClientName(player.id, name, MAX_NAME_LENGTH);
	SQL_EscapeString(gH_DB, name, nameEscaped, MAX_NAME_LENGTH * 2 + 1);
	GetClientAuthId(player.id, AuthId_SteamID64, steamID, sizeof(steamID), true);
	GetClientIP(player.id, clientIP, sizeof(clientIP));
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
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupClient, DB_TxnFailure_Generic, player, DBPrio_High);
}

public void DB_TxnSuccess_SetupClient(Handle db, KZPlayer player, int numQueries, Handle[] results, any[] queryData) {
	if (!IsClientAuthorized(player.id)) {  // Client is no longer authorised so don't continue
		return;
	}
	
	// Retrieve PlayerID from results
	switch (g_DBType) {
		case DatabaseType_SQLite: {
			if (SQL_FetchRow(results[2])) {
				gI_DBPlayerID[player.id] = SQL_FetchInt(results[2], 0);
				Call_SimpleKZ_OnRetrievePlayerID(player.id);
			}
		}
		case DatabaseType_MySQL: {
			if (SQL_FetchRow(results[1])) {
				gI_DBPlayerID[player.id] = SQL_FetchInt(results[1], 0);
				Call_SimpleKZ_OnRetrievePlayerID(player.id);
			}
		}
	}
	
	// Load options now that PlayerID has been retrieved
	DB_LoadOptions(player);
}



/*===============================  Options  ===============================*/

void DB_LoadOptions(KZPlayer player) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get options for the client's PlayerID
	FormatEx(query, sizeof(query), sql_options_get, player.db_playerID);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_LoadOptions, DB_TxnFailure_Generic, player, DBPrio_High);
}

public void DB_TxnSuccess_LoadOptions(Handle db, KZPlayer player, int numQueries, Handle[] results, any[] queryData) {
	if (!IsClientAuthorized(player.id)) {  // Client is no longer authorised so don't continue
		return;
	}
	
	else if (SQL_GetRowCount(results[0]) == 0) {
		// No options found for that PlayerID, so insert those options and then try reload them again
		char query[512];
		
		Transaction txn = SQL_CreateTransaction();
		
		// Insert options
		FormatEx(query, sizeof(query), sql_options_insert, player.db_playerID, SimpleKZ_GetDefaultStyle());
		txn.AddQuery(query);
		
		SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_InsertOptions, DB_TxnFailure_Generic, player, DBPrio_High);
	}
	
	else if (SQL_FetchRow(results[0])) {
		player.style = view_as<KZStyle>(SQL_FetchInt(results[0], 0));
		player.showingTeleportMenu = view_as<KZShowingTeleportMenu>(SQL_FetchInt(results[0], 1));
		player.showingInfoPanel = view_as<KZShowingInfoPanel>(SQL_FetchInt(results[0], 2));
		player.showingKeys = view_as<KZShowingKeys>(SQL_FetchInt(results[0], 3));
		player.showingPlayers = view_as<KZShowingPlayers>(SQL_FetchInt(results[0], 4));
		player.showingWeapon = view_as<KZShowingWeapon>(SQL_FetchInt(results[0], 5));
		player.autoRestart = view_as<KZAutoRestart>(SQL_FetchInt(results[0], 6));
		player.slayOnEnd = view_as<KZSlayOnEnd>(SQL_FetchInt(results[0], 7));
		player.pistol = view_as<KZPistol>(SQL_FetchInt(results[0], 8));
		player.checkpointMessages = view_as<KZCheckpointMessages>(SQL_FetchInt(results[0], 9));
		player.checkpointSounds = view_as<KZCheckpointSounds>(SQL_FetchInt(results[0], 10));
		player.teleportSounds = view_as<KZTeleportSounds>(SQL_FetchInt(results[0], 11));
		player.timerText = view_as<KZTimerText>(SQL_FetchInt(results[0], 12));
	}
}

public void DB_TxnSuccess_InsertOptions(Handle db, KZPlayer player, int numQueries, Handle[] results, any[] queryData) {
	DB_LoadOptions(player);
}

void DB_SaveOptions(KZPlayer player) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Update options
	FormatEx(query, sizeof(query), 
		sql_options_update, 
		player.style, 
		player.showingTeleportMenu, 
		player.showingInfoPanel, 
		player.showingKeys, 
		player.showingPlayers, 
		player.showingWeapon, 
		player.autoRestart, 
		player.slayOnEnd, 
		player.pistol, 
		player.checkpointMessages, 
		player.checkpointSounds, 
		player.teleportSounds, 
		player.timerText, 
		gI_DBPlayerID[player.id]);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic, _, DBPrio_High);
}



/*===============================  Maps  ===============================*/

void DB_SetupMap() {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	
	char map[64];
	GetCurrentMap(map, sizeof(map));
	// Get just the map name (e.g. remove workshop/id/ prefix)
	char mapPieces[5][64];
	int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(map, sizeof(map), "%s", mapPieces[lastPiece - 1]);
	String_ToLower(map, map, sizeof(map));
	
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
				gI_DBCurrentMapID = SQL_FetchInt(results[2], 0);
				Call_SimpleKZ_OnRetrieveCurrentMapID();
			}
		}
		case DatabaseType_MySQL: {
			if (SQL_FetchRow(results[1])) {
				gI_DBCurrentMapID = SQL_FetchInt(results[1], 0);
				Call_SimpleKZ_OnRetrieveCurrentMapID();
			}
		}
	}
}



/*===============================  Times  ===============================*/

void DB_StoreTime(KZPlayer player, int course, KZStyle style, float runTime, int teleportsUsed, float theoreticalRunTime) {
	if (!gB_ConnectedToDB) {
		return;
	}
	
	char query[512];
	int playerID = gI_DBPlayerID[player.id];
	int mapID = SimpleKZ_GetCurrentMapID();
	int runTimeMS = SimpleKZ_TimeFloatToInt(runTime);
	int theoreticalRunTimeMS = SimpleKZ_TimeFloatToInt(theoreticalRunTime);
	
	DataPack data = CreateDataPack();
	data.WriteCell(player.id);
	data.WriteCell(playerID);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteCell(runTimeMS);
	data.WriteCell(teleportsUsed);
	data.WriteCell(theoreticalRunTimeMS);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Save runTime to DB
	FormatEx(query, sizeof(query), sql_times_insert, playerID, mapID, course, style, runTimeMS, teleportsUsed, theoreticalRunTimeMS);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SaveTime, DB_TxnFailure_Generic, data, DBPrio_Normal);
}

public void DB_TxnSuccess_SaveTime(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData) {
	data.Reset();
	int client = data.ReadCell();
	int playerID = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	int runTimeMS = data.ReadCell();
	int teleportsUsed = data.ReadCell();
	int theoreticalTimeMS = data.ReadCell();
	CloseHandle(data);
	
	Call_SimpleKZ_OnStoreTimeInDB(client, playerID, mapID, course, style, runTimeMS, teleportsUsed, theoreticalTimeMS);
} 