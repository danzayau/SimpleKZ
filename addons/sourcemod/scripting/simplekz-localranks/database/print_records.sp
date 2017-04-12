/*
	Database - Print Records
	
	Prints the record times on a map course and given style.
*/

void DB_PrintRecords(int client, int mapID, int course, KZStyle style)
{
	char query[1024];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	// Check for existence of map course with that MapID and Course
	FormatEx(query, sizeof(query), sql_mapcourses_findid, mapID, course);
	txn.AddQuery(query);
	
	// Get Map WR
	FormatEx(query, sizeof(query), sql_getmaptop, mapID, course, style, 1);
	txn.AddQuery(query);
	// Get PRO WR
	FormatEx(query, sizeof(query), sql_getmaptoppro, mapID, course, style, 1);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintRecords, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintRecords(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	char mapName[33];
	
	bool mapHasRecord = false;
	bool mapHasRecordPro = false;
	
	char recordHolder[33];
	float runTime;
	int teleportsUsed;
	
	char recordHolderPro[33];
	float runTimePro;
	
	// Get Map Name from results
	if (SQL_FetchRow(results[0]))
	{
		SQL_FetchString(results[0], 0, mapName, sizeof(mapName));
	}
	// Check if the map course exists in the database
	if (SQL_GetRowCount(results[1]) == 0)
	{
		if (course == 0)
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "Main Course Not Found", mapName);
		}
		else
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "Bonus Not Found", mapName, course);
		}
		return;
	}
	
	// Get WR info from results
	if (SQL_GetRowCount(results[2]) > 0)
	{
		mapHasRecord = true;
		if (SQL_FetchRow(results[2]))
		{
			SQL_FetchString(results[2], 0, recordHolder, sizeof(recordHolder));
			runTime = SKZ_TimeIntToFloat(SQL_FetchInt(results[2], 1));
			teleportsUsed = SQL_FetchInt(results[2], 2);
		}
	}
	// Get Pro WR info from results
	if (SQL_GetRowCount(results[3]) > 0)
	{
		mapHasRecordPro = true;
		if (SQL_FetchRow(results[3]))
		{
			SQL_FetchString(results[3], 0, recordHolderPro, sizeof(recordHolderPro));
			runTimePro = SKZ_TimeIntToFloat(SQL_FetchInt(results[3], 1));
		}
	}
	
	// Print WR header to chat
	if (course == 0)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "WR Header", mapName, gC_StylePhrases[style]);
	}
	else
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "WR Header (Bonus)", mapName, course, gC_StylePhrases[style]);
	}
	
	// Print WR times to chat
	if (!mapHasRecord)
	{
		CPrintToChat(client, "  %t", "WR No Times");
	}
	else if (!mapHasRecordPro)
	{
		CPrintToChat(client, "  %t", "WR Time - Map", SKZ_FormatTime(runTime), teleportsUsed, recordHolder);
		CPrintToChat(client, "  %t", "WR Time - No Pro Time");
	}
	else if (teleportsUsed == 0)
	{
		CPrintToChat(client, "  %t", "WR Time - Map (Pro)", SKZ_FormatTime(runTimePro), recordHolderPro);
	}
	else
	{
		CPrintToChat(client, "  %t", "WR Time - Map", SKZ_FormatTime(runTime), teleportsUsed, recordHolder);
		CPrintToChat(client, "  %t", "WR Time - Pro", SKZ_FormatTime(runTimePro), recordHolderPro);
	}
}

void DB_PrintRecords_FindMap(int client, const char[] mapSearch, int course, KZStyle style)
{
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindMap(mapSearch, DB_TxnSuccess_PrintRecords_FindMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintRecords_FindMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	char mapSearch[33];
	data.ReadString(mapSearch, sizeof(mapSearch));
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0]))
	{  // Result is the MapID
		DB_PrintRecords(client, SQL_FetchInt(results[0], 0), course, style);
	}
} 