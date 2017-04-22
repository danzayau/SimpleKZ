/*
	Database - Setup Client
	
	Inserts the player into the database, or else updates their information.
	Retrieves the PlayerID of the player and stores it in a global variable.
*/

void DB_SetupClient(KZPlayer player)
{
	if (IsFakeClient(player.id))
	{
		return;
	}
	
	// Setup Client Step 1 - Upsert them into Players Table	
	char query[1024], name[MAX_NAME_LENGTH], nameEscaped[MAX_NAME_LENGTH * 2 + 1], steamID[18], clientIP[16], country[45];
	if (!GetClientName(player.id, name, MAX_NAME_LENGTH))
	{
		SetFailState("Couldn't get name of %L.", player.id);
	}
	SQL_EscapeString(gH_DB, name, nameEscaped, MAX_NAME_LENGTH * 2 + 1);
	if (!GetClientAuthId(player.id, AuthId_SteamID64, steamID, sizeof(steamID), true))
	{
		SetFailState("Couldn't get SteamID64 of %L.", player.id);
	}
	if (!GetClientIP(player.id, clientIP, sizeof(clientIP)))
	{
		SetFailState("Couldn't get IP of %L.", player.id);
	}
	if (!GeoipCountry(clientIP, country, sizeof(country)))
	{
		country = "Unknown";
	}
	
	Transaction txn = SQL_CreateTransaction();
	
	// Insert/Update player into Players table
	switch (g_DBType)
	{
		case DatabaseType_SQLite:
		{
			// UPDATE OR IGNORE
			FormatEx(query, sizeof(query), sqlite_players_update, nameEscaped, country, clientIP, steamID);
			txn.AddQuery(query);
			// INSERT OR IGNORE
			FormatEx(query, sizeof(query), sqlite_players_insert, nameEscaped, country, clientIP, steamID);
			txn.AddQuery(query);
		}
		case DatabaseType_MySQL:
		{
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

public void DB_TxnSuccess_SetupClient(Handle db, KZPlayer player, int numQueries, Handle[] results, any[] queryData)
{
	if (!IsClientAuthorized(player.id))
	{
		return;
	}
	
	// Retrieve PlayerID from results
	switch (g_DBType)
	{
		case DatabaseType_SQLite:
		{
			if (SQL_FetchRow(results[2]))
			{
				gI_DBPlayerID[player.id] = SQL_FetchInt(results[2], 0);
				Call_SKZ_OnRetrievePlayerID(player.id);
			}
		}
		case DatabaseType_MySQL:
		{
			if (SQL_FetchRow(results[1]))
			{
				gI_DBPlayerID[player.id] = SQL_FetchInt(results[1], 0);
				Call_SKZ_OnRetrievePlayerID(player.id);
			}
		}
	}
} 