/*
	Database - Open Player Top 20
	
	Opens the menu with top 20 record holders for the time type and given style.
	See also:
		menus/playertop.sp
*/

void DB_OpenPlayerTop20(int client, KZTimeType timeType, KZStyle style)
{
	char query[1024];
	
	DataPack data = CreateDataPack();
	data.WriteCell(client);
	data.WriteCell(timeType);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get top 20 players
	switch (timeType) {
		case KZTimeType_Normal:
		{
			FormatEx(query, sizeof(query), sql_gettopplayers_map, style);
			txn.AddQuery(query);
		}
		case KZTimeType_Pro:
		{
			FormatEx(query, sizeof(query), sql_gettopplayers_pro, style);
			txn.AddQuery(query);
		}
		case KZTimeType_Theoretical:
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
	KZStyle style = data.ReadCell();
	CloseHandle(data);
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0)
	{
		switch (timeType)
		{
			case KZTimeType_Normal:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times");
			case KZTimeType_Pro:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times (Pro)");
			case KZTimeType_Theoretical:CPrintToChat(client, "%t %t", "KZ Prefix", "Player Top - No Times");
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