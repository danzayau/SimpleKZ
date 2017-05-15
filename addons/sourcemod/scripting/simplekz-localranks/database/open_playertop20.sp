/*
	Database - Open Player Top 20
	
	Opens the menu with top 20 record holders for the time type and given style.
	See also:
		menus/playertop.sp
*/



void DB_OpenPlayerTop20(int client, int timeType, int style)
{
	char query[1024];
	
	DataPack data = new DataPack();
	data.WriteCell(client);
	data.WriteCell(timeType);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get top 20 players
	switch (timeType) {
		case TimeType_Nub:
		{
			FormatEx(query, sizeof(query), sql_gettopplayers_map, style);
			txn.AddQuery(query);
		}
		case TimeType_Pro:
		{
			FormatEx(query, sizeof(query), sql_gettopplayers_pro, style);
			txn.AddQuery(query);
		}
		case TimeType_Theoretical:
		{
			FormatEx(query, sizeof(query), sql_gettopplayers_theoretical, style);
			txn.AddQuery(query);
		}
	}
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenPlayerTop20, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenPlayerTop20(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	KZRecordType timeType = data.ReadCell();
	int style = data.ReadCell();
	data.Close();
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0)
	{
		switch (timeType)
		{
			case TimeType_Nub:SKZ_PrintToChat(client, true, "%t", "Player Top - No Times");
			case TimeType_Pro:SKZ_PrintToChat(client, true, "%t", "Player Top - No Times (Pro)");
			case TimeType_Theoretical:SKZ_PrintToChat(client, true, "%t", "Player Top - No Times");
		}
		PlayerTopMenuDisplay(client);
		return;
	}
	
	RemoveAllMenuItems(gH_PlayerTopSubMenu[client]);
	
	// Set submenu title
	SetMenuTitle(gH_PlayerTopSubMenu[client], "%T", "Player Top Submenu - Title", client, 
		gC_TimeTypePhrases[timeType], gC_StylePhrases[style]);
	
	// Add submenu items
	char newMenuItem[256];
	int rank = 0;
	while (SQL_FetchRow(results[0]))
	{
		rank++;
		char playerString[33];
		SQL_FetchString(results[0], 0, playerString, sizeof(playerString));
		FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %s (%d)", rank, playerString, SQL_FetchInt(results[0], 1));
		AddMenuItem(gH_PlayerTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_PlayerTopSubMenu[client], client, MENU_TIME_FOREVER);
} 