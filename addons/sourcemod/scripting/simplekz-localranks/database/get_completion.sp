/*
	Database - Get Completion
	
	Gets the number and percentage of maps completed.
*/

void DB_GetCompletion(int client, int targetPlayerID, KZStyle style, bool print)
{
	char query[1024];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(targetPlayerID);
	data.WriteCell(style);
	data.WriteCell(print);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Alias of PlayerID
	FormatEx(query, sizeof(query), sql_players_getalias, targetPlayerID);
	txn.AddQuery(query);
	// Get total number of ranked main courses
	txn.AddQuery(sql_getcount_maincourses);
	// Get number of main course completions
	FormatEx(query, sizeof(query), sql_getcount_maincoursescompleted, targetPlayerID, style);
	txn.AddQuery(query);
	// Get number of main course completions (PRO)
	FormatEx(query, sizeof(query), sql_getcount_maincoursescompletedpro, targetPlayerID, style);
	txn.AddQuery(query);
	
	// Get total number of ranked bonuses
	txn.AddQuery(sql_getcount_bonuses);
	// Get number of bonus completions
	FormatEx(query, sizeof(query), sql_getcount_bonusescompleted, targetPlayerID, style);
	txn.AddQuery(query);
	// Get number of bonus completions (PRO)
	FormatEx(query, sizeof(query), sql_getcount_bonusescompletedpro, targetPlayerID, style);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_GetCompletion, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_GetCompletion(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int targetPlayerID = data.ReadCell();
	KZStyle style = data.ReadCell();
	bool print = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	char playerName[MAX_NAME_LENGTH];
	int totalMainCourses, completions, completionsPro;
	int totalBonuses, bonusCompletions, bonusCompletionsPro;
	
	// Get Player Name from results
	if (SQL_FetchRow(results[0]))
	{
		SQL_FetchString(results[0], 0, playerName, sizeof(playerName));
	}
	
	// Get total number of main courses
	if (SQL_FetchRow(results[1]))
	{
		totalMainCourses = SQL_FetchInt(results[1], 0);
	}
	// Get completed main courses
	if (SQL_FetchRow(results[2]))
	{
		completions = SQL_FetchInt(results[2], 0);
	}
	// Get completed main courses (PRO)
	if (SQL_FetchRow(results[3]))
	{
		completionsPro = SQL_FetchInt(results[3], 0);
	}
	
	// Get total number of bonuses
	if (SQL_FetchRow(results[4]))
	{
		totalBonuses = SQL_FetchInt(results[4], 0);
	}
	// Get completed bonuses
	if (SQL_FetchRow(results[5])) {
		bonusCompletions = SQL_FetchInt(results[5], 0);
	}
	// Get completed bonuses (PRO)
	if (SQL_FetchRow(results[6]))
	{
		bonusCompletionsPro = SQL_FetchInt(results[6], 0);
	}
	
	// Print completion message to chat if specified
	if (print)
	{
		if (totalMainCourses + totalBonuses == 0)
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "No Ranked Maps");
		}
		else
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "Map Completion", 
				playerName, 
				completions, totalMainCourses, completionsPro, totalMainCourses, 
				bonusCompletions, totalBonuses, bonusCompletionsPro, totalBonuses, 
				gC_StylePhrases[style]);
		}
	}
	
	// Set scoreboard MVP stars to percentage PRO completion of server's default style
	if (totalMainCourses + totalBonuses != 0 && targetPlayerID == SKZ_GetPlayerID(client) && style == SKZ_GetDefaultStyle())
	{
		CS_SetMVPCount(client, RoundToFloor(float(completionsPro + bonusCompletionsPro) / float(totalMainCourses + totalBonuses) * 100.0));
	}
}

void DB_GetCompletion_FindPlayer(int client, const char[] target, KZStyle style)
{
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteString(target);
	data.WriteCell(style);
	
	DB_FindPlayer(target, DB_TxnSuccess_GetCompletion_FindPlayer, data, DBPrio_Low);
}

public void DB_TxnSuccess_GetCompletion_FindPlayer(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	char playerSearch[33];
	data.ReadString(playerSearch, sizeof(playerSearch));
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	else if (SQL_GetRowCount(results[0]) == 0)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Player Not Found", playerSearch);
		return;
	}
	else if (SQL_FetchRow(results[0]))
	{  // Result is the PlayerID
		DB_GetCompletion(client, SQL_FetchInt(results[0], 0), style, true);
	}
} 