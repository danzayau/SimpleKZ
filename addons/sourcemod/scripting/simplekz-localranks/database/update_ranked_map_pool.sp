/*
	Database - Update Ranked Map Pool
	
	Inserts a list of maps read from a file into the Maps table,
	and updates them to be part of the ranked map pool.
*/



#define FILE_PATH_MAPPOOL "cfg/sourcemod/simplekz/mappool.cfg"



void DB_UpdateRankedMapPool(int client)
{
	Handle file = OpenFile(FILE_PATH_MAPPOOL, "r");
	if (file == null)
	{
		LogError("There was a problem opening file: %s", FILE_PATH_MAPPOOL);
		if (IsValidClient(client))
		{
			PrintToChat(client, "[SimpleKZ] There was a problem opening file: %s", FILE_PATH_MAPPOOL);
		}
		return;
	}
	
	char line[33], query[512];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Reset all maps to be unranked
	txn.AddQuery(sql_maps_reset_mappool);
	// Insert/Update maps in mappool.cfg to be ranked
	while (ReadFileLine(file, line, sizeof(line)))
	{
		TrimString(line);
		if (line[0] == '\0' || line[0] == ';' || (line[0] == '/' && line[1] == '/'))
		{
			continue;
		}
		String_ToLower(line, line, sizeof(line));
		switch (g_DBType)
		{
			case DatabaseType_SQLite:
			{
				// UPDATE OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_updateranked, 1, line);
				txn.AddQuery(query);
				// INSERT OR IGNORE
				FormatEx(query, sizeof(query), sqlite_maps_insertranked, 1, line);
				txn.AddQuery(query);
			}
			case DatabaseType_MySQL:
			{
				FormatEx(query, sizeof(query), mysql_maps_upsertranked, 1, line);
				txn.AddQuery(query);
			}
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_UpdateRankedMapPool, DB_TxnFailure_Generic, client, DBPrio_Low);
	
	CloseHandle(file);
}

public void DB_TxnSuccess_UpdateRankedMapPool(Handle db, int client, int numQueries, Handle[] results, any[] queryData)
{
	LogMessage("The ranked map pool was updated by %L.", client);
	if (IsValidClient(client))
	{
		PrintToChat(client, "[SimpleKZ] The ranked map pool was updated.");
	}
} 