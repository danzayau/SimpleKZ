/*	database.sp
	
	Optional database for SimpleKZ.
*/


/*===============================  Queries  ===============================*/

// Players
char sql_players_create[] = 
"CREATE TABLE IF NOT EXISTS Players ("
..."SteamID VARCHAR(24) NOT NULL, "
..."Alias VARCHAR(33) NOT NULL, "
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

// Maps
char sql_maps_create[] = 
"CREATE TABLE IF NOT EXISTS Maps ("
..."Map VARCHAR(32) NOT NULL, "
..."Tier TINYINT UNSIGNED, "
..."CONSTRAINT PK_Maps PRIMARY KEY (Map));";

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
"INSERT INTO Preferences "
..."(SteamID) "
..."VALUES('%s');";

char sql_preferences_update[] = 
"UPDATE Preferences "
..."SET ShowingTeleportMenu='%d', ShowingInfoPanel='%d', ShowingKeys='%d', ShowingPlayers='%d', ShowingWeapon='%d', Pistol='%d' "
..."WHERE SteamID='%s';";

char sql_preferences_select[] = 
"SELECT ShowingTeleportMenu, ShowingInfoPanel, ShowingKeys, ShowingPlayers, ShowingWeapon, Pistol "
..."FROM Preferences "
..."WHERE SteamID='%s';";


// TimesPRO
char sql_timespro_create[] = 
"CREATE TABLE IF NOT EXISTS TimesPro ("
..."SteamID VARCHAR(24) NOT NULL, "
..."Map VARCHAR(32) NOT NULL, "
..."RunTime FLOAT UNSIGNED NOT NULL, "
..."RunTimestamp TIMESTAMP NOT NULL, "
..."CONSTRAINT PK_TimesPro PRIMARY KEY (SteamID, Map), "
..."CONSTRAINT FK_TimesPro_SteamID FOREIGN KEY (SteamID) REFERENCES Players (SteamID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_TimesPro_Map FOREIGN KEY (Map) REFERENCES Maps (Map) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_timespro_selectpb[] = 
"SELECT RunTime "
..."FROM TimesPRO "
..."WHERE SteamID='%s' AND Map='%s';";

char sql_timespro_insertpb[] = 
"INSERT INTO TimesPro "
..."(RunTime, RunTimestamp, SteamID, Map) "
..."VALUES('%f', CURRENT_TIMESTAMP, '%s', '%s');";

char sql_timespro_updatepb[] = 
"UPDATE TimesPro"
..."SET RunTime='%f', RunTimestamp=CURRENT_TIMESTAMP "
..."WHERE SteamID='%s' AND Map='%s';";


// TimesTP
char sql_timestp_create[] = 
"CREATE TABLE IF NOT EXISTS TimesTP ("
..."SteamID VARCHAR(24) NOT NULL, "
..."Map VARCHAR(32) NOT NULL, "
..."RunTime FLOAT UNSIGNED NOT NULL, "
..."Teleports SMALLINT UNSIGNED NOT NULL, "
..."TheoreticalRunTime FLOAT UNSIGNED NOT NULL, "
..."RunTimestamp TIMESTAMP NOT NULL, "
..."CONSTRAINT PK_TimesTP PRIMARY KEY (SteamID, Map), "
..."CONSTRAINT FK_TimesTP_SteamID FOREIGN KEY (SteamID) REFERENCES Players (SteamID) ON UPDATE CASCADE ON DELETE CASCADE, "
..."CONSTRAINT FK_TimesTP_Map FOREIGN KEY (Map) REFERENCES Maps (Map) ON UPDATE CASCADE ON DELETE CASCADE);";

char sql_timestp_selectpb[] = 
"SELECT RunTime, Teleports, WastedTime "
..."FROM TimesTP "
..."WHERE SteamID='%s' AND Map='%s';";

char sql_timestp_insertpb[] = 
"INSERT INTO TimesTP "
..."(RunTime, Teleports, TheoreticalRunTime, RunTimestamp, SteamID, Map) "
..."VALUES('%f', '%i', '%f', CURRENT_TIMESTAMP, '%s', '%s');";

char sql_timestp_updatepb[] = 
"UPDATE TimesTP"
..."SET RunTime='%f', Teleports='%d', TheoreticalRunTime='%f', RunTimestamp=CURRENT_TIMESTAMP "
..."WHERE SteamID='%s' AND Map='%s';";




/*===============================  General  ===============================*/

void DB_SetupDatabase() {
	char error[255];
	gH_DB = SQL_Connect("simplekz", true, error, sizeof(error));
	if (gH_DB != INVALID_HANDLE) {
		gB_ConnectedToDB = true;
		DB_CreateTables();
	}
}

void DB_CreateTables() {
	Transaction createTables = SQL_CreateTransaction();
	createTables.AddQuery(sql_players_create);
	createTables.AddQuery(sql_maps_create);
	createTables.AddQuery(sql_preferences_create);
	createTables.AddQuery(sql_timespro_create);
	createTables.AddQuery(sql_timestp_create);
	SQL_ExecuteTransaction(gH_DB, createTables, INVALID_FUNCTION, DB_Callback_TransactionError, 0, DBPrio_High);
}

void DB_LoadPBs(int client) {
	if (gB_ConnectedToDB) {
		DB_LoadPBPro(client);
		DB_LoadPBTP(client);
	}
	else {
		gB_HasPBPro[client] = false;
		gB_HasPBTP[client] = false;
	}
}

void DB_ProcessEndTimer(int client) {
	if (gB_ConnectedToDB) {
		if (gI_TeleportsUsed[client] == 0) {
			DB_EndTimerPro(client);
		}
		else {
			DB_EndTimerTP(client);
		}
	}
}

// Error check callback for queries don't return any results
public void DB_Callback_ErrorCheck(Handle database, Handle results, const char[] error, any client) {
	if (results == INVALID_HANDLE) {
		SetFailState("[SimpleKZ] Database query error: %s", error);
	}
}

// Error report callback for failed transactions
public void DB_Callback_TransactionError(Handle db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	SetFailState("[SimpleKZ] Database query error: %s", error);
}



/*===============================  Players  ===============================*/

void DB_SavePlayerInfo(int client) {
	if (gB_ConnectedToDB) {
		char query[256], clientName[MAX_NAME_LENGTH], clientNameEscaped[MAX_NAME_LENGTH * 2 + 1];
		GetClientName(client, clientName, MAX_NAME_LENGTH);
		SQL_EscapeString(gH_DB, clientName, clientNameEscaped, MAX_NAME_LENGTH * 2 + 1);
		// UPDATE
		FormatEx(query, sizeof(query), sql_players_update, clientNameEscaped, gC_Country[client], gC_SteamID[client]);
		SQL_TQuery(gH_DB, DB_Callback_ErrorCheck, query);
		// INSERT (ensure there is a row for the player)
		FormatEx(query, sizeof(query), sql_players_insert, clientNameEscaped, gC_Country[client], gC_SteamID[client]);
		SQL_TQuery(gH_DB, DB_Callback_ErrorCheck, query);
	}
}



/*===============================  Preferences  ===============================*/

void DB_LoadPreferences(int client) {
	if (gB_ConnectedToDB) {
		char query[256];
		// SELECT
		FormatEx(query, 2 * sizeof(query) - 1, sql_preferences_select, gC_SteamID[client]);
		SQL_TQuery(gH_DB, DB_Callback_LoadPreferences, query, client);
	}
	else {  // Load some default values
		gB_ShowingTeleportMenu[client] = true;
		gB_ShowingInfoPanel[client] = true;
		gB_ShowingKeys[client] = false;
		gB_ShowingPlayers[client] = true;
		gB_ShowingWeapon[client] = true;
		gI_Pistol[client] = 0;
	}
}

public void DB_Callback_LoadPreferences(Handle db, Handle results, const char[] error, any client) {
	if (SQL_GetRowCount(results) == 0) {
		char query[256];
		FormatEx(query, sizeof(query), sql_preferences_insert, gC_SteamID[client]);
		SQL_TQuery(gH_DB, DB_Callback_InsertPreferences, query, client);
	}
	if (SQL_FetchRow(results)) {
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

public void DB_Callback_InsertPreferences(Handle db, Handle results, const char[] error, any client) {
	DB_LoadPreferences(client);
}

void DB_UpdatePreferences(int client) {
	if (gB_ConnectedToDB) {
		char query[256];
		FormatEx(query, sizeof(query), 
			sql_preferences_update, 
			BoolToInt(gB_ShowingTeleportMenu[client]), 
			BoolToInt(gB_ShowingInfoPanel[client]), 
			BoolToInt(gB_ShowingKeys[client]), 
			BoolToInt(gB_ShowingPlayers[client]), 
			BoolToInt(gB_ShowingWeapon[client]), 
			gI_Pistol[client], 
			gC_SteamID[client]);
		SQL_TQuery(gH_DB, DB_Callback_ErrorCheck, query, client);
	}
}



/*===============================  TimesPRO  ===============================*/

void DB_LoadPBPro(int client) {
	char query[256];
	FormatEx(query, sizeof(query), 
		sql_timespro_selectpb, 
		gC_SteamID[client], 
		gC_CurrentMap);
	SQL_TQuery(gH_DB, DB_Callback_LoadPBPro, query, client);
}

public void DB_Callback_LoadPBPro(Handle db, Handle results, const char[] error, any client) {
	if (SQL_GetRowCount(results) == 0) {
		// No PB Found
		gB_HasPBPro[client] = false;
	}
	if (SQL_FetchRow(results)) {
		gB_HasPBPro[client] = true;
		gF_PBProTime[client] = SQL_FetchFloat(results, 0);
	}
}

void DB_EndTimerPro(int client) {
	if (!gB_HasPBPro[client]) {
		gB_HasPBPro[client] = true;
		gF_PBProTime[client] = gF_CurrentTime[client];
		// INSERT the new PB
		char query[256];
		FormatEx(query, sizeof(query), 
			sql_timespro_insertpb, 
			gF_CurrentTime[client], 
			gC_SteamID[client], 
			gC_CurrentMap);
		SQL_TQuery(gH_DB, DB_Callback_SavePBPro, query, client);
	}
	else if (gB_HasPBPro[client] && gF_CurrentTime[client] < gF_PBProTime[client]) {
		gF_PBProTime[client] = gF_CurrentTime[client];
		// UPDATE the stored PB
		char query[256];
		FormatEx(query, sizeof(query), 
			sql_timespro_updatepb, 
			gF_CurrentTime[client], 
			gC_SteamID[client], 
			gC_CurrentMap);
		SQL_TQuery(gH_DB, DB_Callback_SavePBPro, query, client);
	}
}

public void DB_Callback_SavePBPro(Handle db, Handle results, const char[] error, any client) {
	PrintToChat(client, "[Debug] PRO time has been saved to the database.");
}



/*===============================  TimesTP  ===============================*/

void DB_LoadPBTP(int client) {
	char query[256];
	FormatEx(query, sizeof(query), 
		sql_timestp_selectpb, 
		gC_SteamID[client], 
		gC_CurrentMap);
	SQL_TQuery(gH_DB, DB_CallBack_LoadPBTP, query, client);
}

public void DB_CallBack_LoadPBTP(Handle db, Handle results, const char[] error, any client) {
	if (SQL_GetRowCount(results) == 0) {
		// No PB Found
		gB_HasPBTP[client] = false;
	}
	if (SQL_FetchRow(results)) {
		gB_HasPBTP[client] = true;
		gF_PBTPTime[client] = SQL_FetchFloat(results, 0);
		gI_PBTPTeleportsUsed[client] = SQL_FetchInt(results, 1);
		gF_PBTPTheoreticalTime[client] = SQL_FetchFloat(results, 2);
	}
}

void DB_EndTimerTP(int client) {
	if (!(gB_HasPBPro[client] && gF_PBProTime[client] <= gF_CurrentTime[client])) {
		if (!gB_HasPBTP[client]) {
			gB_HasPBTP[client] = true;
			gF_PBTPTime[client] = gF_CurrentTime[client];
			gI_PBTPTeleportsUsed[client] = gI_TeleportsUsed[client];
			gF_PBTPTheoreticalTime[client] = gF_CurrentTime[client] - gF_WastedTime[client];
			// INSERT the new PB
			char query[256];
			FormatEx(query, sizeof(query), 
				sql_timestp_insertpb, 
				gF_CurrentTime[client], 
				gI_TeleportsUsed[client], 
				gF_CurrentTime[client] - gF_WastedTime[client], 
				gC_SteamID[client], 
				gC_CurrentMap);
			SQL_TQuery(gH_DB, DB_Callback_SavePBTP, query, client);
		}
		else if (gB_HasPBTP[client] && gF_CurrentTime[client] < gF_PBTPTime[client]) {
			gF_PBTPTime[client] = gF_CurrentTime[client];
			gI_PBTPTeleportsUsed[client] = gI_TeleportsUsed[client];
			gF_PBTPTheoreticalTime[client] = gF_CurrentTime[client] - gF_WastedTime[client];
			// UPDATE the stored PB
			char query[256];
			FormatEx(query, sizeof(query), 
				sql_timestp_updatepb, 
				gF_CurrentTime[client], 
				gI_TeleportsUsed[client], 
				gF_CurrentTime[client] - gF_WastedTime[client], 
				gC_SteamID[client], 
				gC_CurrentMap);
			SQL_TQuery(gH_DB, DB_Callback_SavePBTP, query, client);
		}
	}
}

public void DB_Callback_SavePBTP(Handle db, Handle results, const char[] error, any client) {
	PrintToChat(client, "[Debug] TP time has been saved to the database.");
} 