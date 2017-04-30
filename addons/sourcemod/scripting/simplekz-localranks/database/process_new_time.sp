/*
	Database - Process New Time
	
	Processes a newly submitted time, determining if the player beat their
	personal best and if they beat the map course and style's record time.
*/

void DB_ProcessNewTime(int client, int steamID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed)
{
	char query[1024];
	
	DataPack data = new DataPack();
	data.WriteCell(client);
	data.WriteCell(steamID);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteCell(runTimeMS);
	data.WriteCell(teleportsUsed);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get Top 2 PBs
	FormatEx(query, sizeof(query), sql_getpb, steamID, mapID, course, style, 2);
	txn.AddQuery(query);
	// Get Rank
	FormatEx(query, sizeof(query), sql_getmaprank, steamID, mapID, course, style, mapID, course, style);
	txn.AddQuery(query);
	// Get Number of Players with Times
	FormatEx(query, sizeof(query), sql_getlowestmaprank, mapID, course, style);
	txn.AddQuery(query);
	
	if (teleportsUsed == 0)
	{
		// Get Top 2 PRO PBs
		FormatEx(query, sizeof(query), sql_getpbpro, steamID, mapID, course, style, 2);
		txn.AddQuery(query);
		// Get PRO Rank
		FormatEx(query, sizeof(query), sql_getmaprankpro, steamID, mapID, course, style, mapID, course, style);
		txn.AddQuery(query);
		// Get Number of Players with PRO Times
		FormatEx(query, sizeof(query), sql_getlowestmaprankpro, mapID, course, style);
		txn.AddQuery(query);
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_ProcessTimerEnd, DB_TxnFailure_Generic, data, DBPrio_Normal);
}

public void DB_TxnSuccess_ProcessTimerEnd(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int steamID = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	int runTimeMS = data.ReadCell();
	int teleportsUsed = data.ReadCell();
	data.Close();
	
	if (!IsValidClient(client) || steamID != GetSteamAccountID(client))
	{
		return;
	}
	
	float runTime = SKZ_DB_TimeIntToFloat(runTimeMS);
	
	bool newPB = false;
	bool firstTime = false;
	float improvement;
	int rank;
	int maxRank;
	
	bool newPBPro = false;
	bool firstTimePro = false;
	float improvementPro;
	int rankPro;
	int maxRankPro;
	
	// Check for new PB
	if (SQL_GetRowCount(results[0]) == 2)
	{
		SQL_FetchRow(results[0]);
		if (runTimeMS == SQL_FetchInt(results[0], 0))
		{
			newPB = true;
			// Time they just beat is second row
			SQL_FetchRow(results[0]);
			improvement = SKZ_DB_TimeIntToFloat(SQL_FetchInt(results[0], 0) - runTimeMS);
		}
	}
	else
	{  // Only 1 row (the time they just got) so this is their first time
		newPB = true;
		firstTime = true;
	}
	
	// If new PB, get rank information
	if (newPB)
	{
		SQL_FetchRow(results[1]);
		rank = SQL_FetchInt(results[1], 0);
		SQL_FetchRow(results[2]);
		maxRank = SQL_FetchInt(results[2], 0);
	}
	
	// Repeat for PRO runs if necessary
	if (teleportsUsed == 0)
	{
		// Check for new PRO PB
		if (SQL_GetRowCount(results[3]) == 2)
		{
			SQL_FetchRow(results[3]);
			if (runTimeMS == SQL_FetchInt(results[3], 0))
			{
				newPBPro = true;
				// Time they just beat is second row
				SQL_FetchRow(results[3]);
				improvementPro = SKZ_DB_TimeIntToFloat(SQL_FetchInt(results[3], 0) - runTimeMS);
			}
		}
		else
		{  // Only 1 row (the time they just got)
			newPBPro = true;
			firstTimePro = true;
		}
		// If new PB, get rank information
		if (newPBPro)
		{
			SQL_FetchRow(results[4]);
			rankPro = SQL_FetchInt(results[4], 0);
			SQL_FetchRow(results[5]);
			maxRankPro = SQL_FetchInt(results[5], 0);
		}
	}
	
	// Call OnNewPersonalBest forward (KZTimeType_Normal)
	if (newPB)
	{
		if (firstTime)
		{
			Call_SKZ_OnNewPersonalBest(client, steamID, mapID, course, style, KZTimeType_Normal, true, runTime, -1.0, rank, maxRank);
		}
		else
		{
			Call_SKZ_OnNewPersonalBest(client, steamID, mapID, course, style, KZTimeType_Normal, false, runTime, improvement, rank, maxRank);
		}
	}
	// Call OnNewPersonalBest forward (KZTimeType_Pro)
	if (newPBPro) {
		if (firstTimePro) {
			Call_SKZ_OnNewPersonalBest(client, steamID, mapID, course, style, KZTimeType_Pro, true, runTime, -1.0, rankPro, maxRankPro);
		}
		else {
			Call_SKZ_OnNewPersonalBest(client, steamID, mapID, course, style, KZTimeType_Pro, false, runTime, improvementPro, rankPro, maxRankPro);
		}
	}
	
	// Call OnNewRecord forward
	if ((newPB && rank == 1) && !(newPBPro && rankPro == 1))
	{
		Call_SKZ_OnNewRecord(client, steamID, mapID, course, style, KZRecordType_Map, runTime);
	}
	else if (!(newPB && rank == 1) && (newPBPro && rankPro == 1))
	{
		Call_SKZ_OnNewRecord(client, steamID, mapID, course, style, KZRecordType_Pro, runTime);
	}
	else if ((newPB && rank == 1) && (newPBPro && rankPro == 1))
	{
		Call_SKZ_OnNewRecord(client, steamID, mapID, course, style, KZRecordType_MapAndPro, runTime);
	}
	
	// Update PRO Completion [Standard] percentage in scoreboard
	if (style == KZStyle_Standard && course == 0 && firstTimePro)
	{
		DB_GetCompletion(client, client, KZStyle_Standard, false);
	}
} 