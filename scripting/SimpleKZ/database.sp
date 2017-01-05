/*	database.sp
	
	Database for player preferences and times.
*/


/*======  Queries  ======*/

char sql_playerpreferences_create[] = "CREATE TABLE IF NOT EXISTS PlayerPreferences (SteamID VARCHAR(24), TeleportMenu INTEGER DEFAULT '1', InfoPanel INTEGER DEFAULT '1', ShowingKeys INTEGER DEFAULT '0', HidingPlayers INTEGER DEFAULT '0', HidingWeapon INTEGER DEFAULT '0', Pistol INTEGER DEFAULT '0', PRIMARY KEY(Steamid));";
char sql_playerpreferences_select[] = "SELECT TeleportMenu, InfoPanel, ShowingKeys, HidingPlayers, HidingWeapon, Pistol FROM PlayerPreferences WHERE SteamID = '%s';";
char sql_playerpreferences_insert[] = "INSERT INTO PlayerPreferences (steamid) VALUES('%s');";
char sql_playerpreferences_update[] = "UPDATE PlayerPreferences SET TeleportMenu='%d', InfoPanel='%d', ShowingKeys='%d', HidingPlayers='%d', HidingWeapon='%d', Pistol='%d' WHERE SteamID = '%s';";



/*======  General  ======*/

void DB_SetupDatabase() {
	char error[255];
	gDB_Database = SQL_Connect("simplekz", true, error, sizeof(error));
	if (gDB_Database != INVALID_HANDLE) {
		gB_ConnectedToDatabase = true;
		DB_CreatePlayerPreferencesTable();
	}
}

// Error check callback for queries don't return any results
public void DB_ErrorCheckCallBack(Handle database, Handle results, const char[] error, any client) {
	if (results == INVALID_HANDLE) {
		SetFailState("[SimpleKZ] Database query failed! %s", error);
	}
}



/*======  Player Preferences  ======*/

void DB_CreatePlayerPreferencesTable() {
	SQL_LockDatabase(gDB_Database);
	SQL_FastQuery(gDB_Database, sql_playerpreferences_create);
	SQL_UnlockDatabase(gDB_Database);
}

void DB_LoadPlayerPreferences(int client) {
	if (gB_ConnectedToDatabase) {
		char query[256];
		FormatEx(query, sizeof(query), sql_playerpreferences_select, gC_SteamID[client]);
		SQL_TQuery(gDB_Database, DB_SelectPlayerPreferencesCallback, query, client);
	}
	else {
		gB_UsingTeleportMenu[client] = true;
		gB_UsingInfoPanel[client] = true;
		gB_ShowingKeys[client] = false;
		gB_HidingPlayers[client] = false;
		gB_HidingWeapon[client] = false;
		gI_Pistol[client] = 0;
	}
}

void DB_SavePlayerPreferences(int client) {
	if (gB_ConnectedToDatabase) {
		char query[256];
		FormatEx(query, sizeof(query), 
			sql_playerpreferences_update, 
			BoolToInt(gB_UsingTeleportMenu[client]), 
			BoolToInt(gB_UsingInfoPanel[client]), 
			BoolToInt(gB_ShowingKeys[client]), 
			BoolToInt(gB_HidingPlayers[client]), 
			BoolToInt(gB_HidingWeapon[client]), 
			gI_Pistol[client], 
			gC_SteamID[client]);
		SQL_TQuery(gDB_Database, DB_ErrorCheckCallBack, query, client);
	}
}

public void DB_SelectPlayerPreferencesCallback(Handle database, Handle results, const char[] error, any client) {
	if (SQL_GetRowCount(results) == 0) {
		char query[256];
		FormatEx(query, sizeof(query), sql_playerpreferences_insert, gC_SteamID[client]);
		SQL_TQuery(gDB_Database, DB_InsertPlayerPreferencesCallback, query, client);
	}
	if (SQL_FetchRow(results)) {
		gB_UsingTeleportMenu[client] = IntToBool(SQL_FetchInt(results, 0));
		gB_UsingInfoPanel[client] = IntToBool(SQL_FetchInt(results, 1));
		gB_ShowingKeys[client] = IntToBool(SQL_FetchInt(results, 2));
		gB_HidingPlayers[client] = IntToBool(SQL_FetchInt(results, 3));
		gB_HidingWeapon[client] = IntToBool(SQL_FetchInt(results, 4));
		gI_Pistol[client] = SQL_FetchInt(results, 5);
	}
}

public void DB_InsertPlayerPreferencesCallback(Handle database, Handle results, const char[] error, any client) {
	DB_LoadPlayerPreferences(client);
} 