/*
	Database - Print Personal Bests
	
	Prints the player's personal times on a map course and given style.
*/

void DB_PrintPBs(int client, int targetPlayerID, int mapID, int course, KZStyle style)
{
	char query[1024];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Alias of PlayerID
	FormatEx(query, sizeof(query), sql_players_getalias, targetPlayerID);
	txn.AddQuery(query);
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	// Check for existence of map course with that MapID and Course
	FormatEx(query, sizeof(query), sql_mapcourses_findid, mapID, course);
	txn.AddQuery(query);
	
	// Get PB
	FormatEx(query, sizeof(query), sql_getpb, targetPlayerID, mapID, course, style, 1);
	txn.AddQuery(query);
	// Get Rank
	FormatEx(query, sizeof(query), sql_getmaprank, targetPlayerID, mapID, course, style, mapID, course, style);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_getlowestmaprank, mapID, course, style);
	txn.AddQuery(query);
	
	// Get PRO PB
	FormatEx(query, sizeof(query), sql_getpbpro, targetPlayerID, mapID, course, style, 1);
	txn.AddQuery(query);
	// Get PRO Rank
	FormatEx(query, sizeof(query), sql_getmaprankpro, targetPlayerID, mapID, course, style, mapID, course, style);
	txn.AddQuery(query);
	// Get Number of Players with PRO Times
	FormatEx(query, sizeof(query), sql_getlowestmaprankpro, mapID, course, style);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_PrintPBs, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintPBs(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
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
	
	char playerName[MAX_NAME_LENGTH], mapName[33];
	
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
	
	// Get Player Name from results
	if (SQL_FetchRow(results[0]))
	{
		SQL_FetchString(results[0], 0, playerName, sizeof(playerName));
	}
	// Get Map Name from results
	if (SQL_FetchRow(results[1]))
	{
		SQL_FetchString(results[1], 0, mapName, sizeof(mapName));
	}
	if (SQL_GetRowCount(results[2]) == 0)
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
	
	// Get PB info from results
	if (SQL_GetRowCount(results[3]) > 0)
	{
		hasPB = true;
		if (SQL_FetchRow(results[3]))
		{
			runTime = SKZ_TimeIntToFloat(SQL_FetchInt(results[3], 0));
			teleportsUsed = SQL_FetchInt(results[3], 1);
			theoreticalRunTime = SKZ_TimeIntToFloat(SQL_FetchInt(results[3], 2));
		}
		if (SQL_FetchRow(results[4]))
		{
			rank = SQL_FetchInt(results[4], 0);
		}
		if (SQL_FetchRow(results[5]))
		{
			maxRank = SQL_FetchInt(results[5], 0);
		}
	}
	// Get PB info (Pro) from results
	if (SQL_GetRowCount(results[6]) > 0)
	{
		hasPBPro = true;
		if (SQL_FetchRow(results[6]))
		{
			runTimePro = SKZ_TimeIntToFloat(SQL_FetchInt(results[6], 0));
		}
		if (SQL_FetchRow(results[7]))
		{
			rankPro = SQL_FetchInt(results[7], 0);
		}
		if (SQL_FetchRow(results[8]))
		{
			maxRankPro = SQL_FetchInt(results[8], 0);
		}
	}
	
	// Print PB header to chat
	if (course == 0)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "PB Header", playerName, mapName, gC_StylePhrases[style]);
	}
	else
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "PB Header (Bonus)", playerName, mapName, course, gC_StylePhrases[style]);
	}
	
	// Print PB times to chat
	if (!hasPB)
	{
		CPrintToChat(client, "  %t", "PB Time - No Times");
	}
	else if (!hasPBPro)
	{
		CPrintToChat(client, "  %t", "PB Time - Map", SKZ_FormatTime(runTime), rank, maxRank, teleportsUsed, SKZ_FormatTime(theoreticalRunTime));
		CPrintToChat(client, "  %t", "PB Time - No Pro Time");
	}
	else if (teleportsUsed == 0)
	{  // Their MAP PB has 0 teleports, and is therefore also their PRO PB
		CPrintToChat(client, "  %t", "PB Time - Map (Pro)", SKZ_FormatTime(runTime), rank, maxRank, rankPro, maxRankPro);
	}
	else
	{
		CPrintToChat(client, "  %t", "PB Time - Map", SKZ_FormatTime(runTime), rank, maxRank, teleportsUsed, SKZ_FormatTime(theoreticalRunTime));
		CPrintToChat(client, "  %t", "PB Time - Pro", SKZ_FormatTime(runTimePro), rankPro, maxRankPro);
	}
}

void DB_PrintPBs_FindMap(int client, int targetPlayerID, const char[] mapSearch, int course, KZStyle style)
{
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(targetPlayerID);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindMap(mapSearch, DB_TxnSuccess_PrintPBs_FindMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintPBs_FindMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int targetPlayerID = data.ReadCell();
	char mapSearch[33];
	data.ReadString(mapSearch, sizeof(mapSearch));
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	// Check if the map course exists in the database
	if (SQL_GetRowCount(results[0]) == 0)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0]))
	{  // Result is the MapID
		DB_PrintPBs(client, targetPlayerID, SQL_FetchInt(results[0], 0), course, style);
	}
}

void DB_PrintPBs_FindPlayerAndMap(int client, const char[] playerSearch, const char[] mapSearch, int course, KZStyle style)
{
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(playerSearch);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindPlayerAndMap(playerSearch, mapSearch, DB_TxnSuccess_PrintPBs_FindPlayerAndMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_PrintPBs_FindPlayerAndMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	char playerSearch[MAX_NAME_LENGTH];
	data.ReadString(playerSearch, sizeof(playerSearch));
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
		CPrintToChat(client, "%t %t", "KZ Prefix", "Player Not Found", playerSearch);
		return;
	}
	else if (SQL_GetRowCount(results[1]) == 0)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0]) && SQL_FetchRow(results[1]))
	{  // Results are Target PlayerID and MapID
		DB_PrintPBs(client, SQL_FetchInt(results[0], 0), SQL_FetchInt(results[1], 0), course, style);
	}
} 