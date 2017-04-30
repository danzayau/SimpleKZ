/*
	Database - Setup Client
	
	Inserts the player into the database, or else updates their information.
*/

void DB_SetupClient(KZPlayer player)
{
	if (IsFakeClient(player.id))
	{
		return;
	}
	
	// Setup Client Step 1 - Upsert them into Players Table
	char query[1024], name[MAX_NAME_LENGTH], nameEscaped[MAX_NAME_LENGTH * 2 + 1], clientIP[16], country[45];
	
	int steamID = GetSteamAccountID(player.id);
	if (!GetClientName(player.id, name, MAX_NAME_LENGTH))
	{
		LogMessage("Couldn't get name of %L.", player.id);
		name = "Unknown";
	}
	SQL_EscapeString(gH_DB, name, nameEscaped, MAX_NAME_LENGTH * 2 + 1);
	if (!GetClientIP(player.id, clientIP, sizeof(clientIP)))
	{
		LogMessage("Couldn't get IP of %L.", player.id);
		clientIP = "Unknown";
	}
	if (!GeoipCountry(clientIP, country, sizeof(country)))
	{
		LogMessage("Couldn't get country of %L.", player.id);
		country = "Unknown";
	}
	
	DataPack data = new DataPack();
	data.WriteCell(player.id);
	data.WriteCell(steamID);
	
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
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SetupPlayer, DB_TxnFailure_Generic, data, DBPrio_High);
}

public void DB_TxnSuccess_SetupPlayer(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int steamID = data.ReadCell();
	
	if (GetSteamAccountID(client) != steamID)
	{
		Call_OnPlayerSetup(-1, steamID); // Not the same client anymore.
	}
	else
	{
		Call_OnPlayerSetup(client, steamID);
	}
} 