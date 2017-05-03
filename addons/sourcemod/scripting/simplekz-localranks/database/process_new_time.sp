/*
	Database - Process New Time
	
	Processes a newly submitted time, determining if the player beat their
	personal best and if they beat the map course and style's record time.
*/

void DB_ProcessNewTime(int client, int steamID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoRunTimeMS)
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
	data.WriteCell(theoRunTimeMS);
	
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
	int theoRunTimeMS = data.ReadCell();
	data.Close();
	
	bool firstTime = SQL_GetRowCount(results[0]) == 1;
	int pbDiff = 0;
	int rank = -1;
	int maxRank = -1;
	if (!firstTime)
	{
		SQL_FetchRow(results[0]);
		int pb = SQL_FetchInt(results[0], 0);
		if (runTimeMS == pb) // New time is new PB
		{
			SQL_FetchRow(results[0]);
			int oldPB = SQL_FetchInt(results[0], 0);
			pbDiff = runTimeMS - oldPB;
		}
		else // Didn't beat PB
		{
			pbDiff = runTimeMS - pb;
		}
	}
	// Get NUB Rank
	SQL_FetchRow(results[1]);
	rank = SQL_FetchInt(results[1], 0);
	SQL_FetchRow(results[2]);
	maxRank = SQL_FetchInt(results[2], 0);
	
	// Repeat for PRO Runs
	bool firstTimePro = false;
	int pbDiffPro = 0;
	int rankPro = -1;
	int maxRankPro = -1;
	if (teleportsUsed == 0)
	{
		firstTimePro = SQL_GetRowCount(results[3]) == 1;
		if (!firstTimePro)
		{
			SQL_FetchRow(results[3]);
			int pb = SQL_FetchInt(results[3], 0);
			if (runTimeMS == pb) // New time is new PB
			{
				SQL_FetchRow(results[3]);
				int oldPB = SQL_FetchInt(results[3], 0);
				pbDiffPro = runTimeMS - oldPB;
			}
			else // Didn't beat PB
			{
				pbDiffPro = runTimeMS - pb;
			}
		}
		// Get PRO Rank
		SQL_FetchRow(results[4]);
		rankPro = SQL_FetchInt(results[4], 0);
		SQL_FetchRow(results[5]);
		maxRankPro = SQL_FetchInt(results[5], 0);
	}
	
	// Call OnTimeProcessed forward
	Call_OnTimeProcessed(
		client, 
		steamID, 
		mapID, 
		course, 
		style, 
		SKZ_DB_TimeIntToFloat(runTimeMS), 
		teleportsUsed, 
		SKZ_DB_TimeIntToFloat(theoRunTimeMS), 
		firstTime, 
		SKZ_DB_TimeIntToFloat(pbDiff), 
		rank, 
		maxRank, 
		firstTimePro, 
		SKZ_DB_TimeIntToFloat(pbDiffPro), 
		rankPro, 
		maxRankPro);
	
	// Call OnNewRecord forward
	bool newWR = (firstTime || pbDiff < 0) && rank == 1;
	bool newWRPro = (firstTimePro || pbDiffPro < 0) && rankPro == 1;
	if (newWR && newWRPro)
	{
		Call_OnNewRecord(client, steamID, mapID, course, style, KZRecordType_NubAndPro);
	}
	else if (newWR)
	{
		Call_OnNewRecord(client, steamID, mapID, course, style, KZRecordType_Nub);
	}
	else if (newWRPro)
	{
		Call_OnNewRecord(client, steamID, mapID, course, style, KZRecordType_Pro);
	}
} 