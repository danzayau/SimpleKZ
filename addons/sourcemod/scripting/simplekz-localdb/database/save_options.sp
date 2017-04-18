/*
	Database - Save Options
	
	Saves player options to the database.
*/

void DB_SaveOptions(KZPlayer player)
{
	char query[1024];
	
	Transaction txn = SQL_CreateTransaction();
	
	// Update options
	FormatEx(query, sizeof(query), 
		sql_options_update, 
		player.style, 
		player.showingTPMenu, 
		player.showingInfoPanel, 
		player.showingKeys, 
		player.showingPlayers, 
		player.showingWeapon, 
		player.autoRestart, 
		player.slayOnEnd, 
		player.pistol, 
		player.checkpointMessages, 
		player.checkpointSounds, 
		player.teleportSounds, 
		player.errorSounds, 
		player.timerText, 
		player.speedText, 
		gI_DBPlayerID[player.id]);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, INVALID_FUNCTION, DB_TxnFailure_Generic, _, DBPrio_High);
} 