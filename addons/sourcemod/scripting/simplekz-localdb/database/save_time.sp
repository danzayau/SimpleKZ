/*
	Database - Save Time
	
	Inserts the player's time into the database.
*/

void DB_SaveTime(KZPlayer player, int course, KZStyle style, float runTime, int teleportsUsed, float theoreticalRunTime)
{
	char query[1024];
	int steamID = GetSteamAccountID(player.id);
	int mapID = SKZ_DB_GetCurrentMapID();
	int runTimeMS = SKZ_DB_TimeFloatToInt(runTime);
	int theoreticalRunTimeMS = SKZ_DB_TimeFloatToInt(theoreticalRunTime);
	
	DataPack data = new DataPack();
	data.WriteCell(player.id);
	data.WriteCell(steamID);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteCell(runTimeMS);
	data.WriteCell(teleportsUsed);
	data.WriteCell(theoreticalRunTimeMS);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Save runTime to DB
	FormatEx(query, sizeof(query), sql_times_insert, steamID, style, runTimeMS, teleportsUsed, theoreticalRunTimeMS, mapID, course);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_SaveTime, DB_TxnFailure_Generic, data, DBPrio_Normal);
}

public void DB_TxnSuccess_SaveTime(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int steamID = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	KZStyle style = data.ReadCell();
	int runTimeMS = data.ReadCell();
	int teleportsUsed = data.ReadCell();
	int theoreticalTimeMS = data.ReadCell();
	data.Close();
	
	Call_OnTimeInserted(client, steamID, mapID, course, style, runTimeMS, teleportsUsed, theoreticalTimeMS);
} 