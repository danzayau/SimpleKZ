/*
	Database - Load Options
	
	Load player options from database.
	
	Notes:
	Inserts the player into the options table if they aren't found,
	then tries to load their options again. This will result in the
	options loaded being the default values in the database.
*/



void DB_LoadOptions(int client)
{
	KZPlayer player = new KZPlayer(client);
	
	char query[1024];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get options for the client
	FormatEx(query, sizeof(query), sql_options_get, GetSteamAccountID(player.id));
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_LoadOptions, DB_TxnFailure_Generic, player, DBPrio_High);
}

public void DB_TxnSuccess_LoadOptions(Handle db, KZPlayer player, int numQueries, Handle[] results, any[] queryData)
{
	if (!IsClientAuthorized(player.id))
	{
		return;
	}
	
	else if (SQL_GetRowCount(results[0]) == 0)
	{
		// No options found for that client, so insert them and try load them again
		char query[1024];
		
		Transaction txn = SQL_CreateTransaction();
		
		// Insert options
		FormatEx(query, sizeof(query), sql_options_insert, GetSteamAccountID(player.id), SKZ_GetDefaultStyle());
		txn.AddQuery(query);
		
		SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_InsertOptions, DB_TxnFailure_Generic, player, DBPrio_High);
	}
	
	else if (SQL_FetchRow(results[0]))
	{
		player.style = SQL_FetchInt(results[0], 0);
		player.showingTPMenu = SQL_FetchInt(results[0], 1);
		player.showingInfoPanel = SQL_FetchInt(results[0], 2);
		player.showingKeys = SQL_FetchInt(results[0], 3);
		player.showingPlayers = SQL_FetchInt(results[0], 4);
		player.showingWeapon = SQL_FetchInt(results[0], 5);
		player.autoRestart = SQL_FetchInt(results[0], 6);
		player.slayOnEnd = SQL_FetchInt(results[0], 7);
		player.pistol = SQL_FetchInt(results[0], 8);
		player.checkpointMessages = SQL_FetchInt(results[0], 9);
		player.checkpointSounds = SQL_FetchInt(results[0], 10);
		player.teleportSounds = SQL_FetchInt(results[0], 11);
		player.errorSounds = SQL_FetchInt(results[0], 12);
		player.timerText = SQL_FetchInt(results[0], 13);
		player.speedText = SQL_FetchInt(results[0], 14);
	}
}

public void DB_TxnSuccess_InsertOptions(Handle db, KZPlayer player, int numQueries, Handle[] results, any[] queryData)
{
	DB_LoadOptions(player.id);
} 