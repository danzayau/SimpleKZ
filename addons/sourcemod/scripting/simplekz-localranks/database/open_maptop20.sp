/*
	Database - Open Map Top 20
	
	Opens the menu with the top 20 times for the map course and given style.
	See also:
		menus/maptop.sp
*/



void DB_OpenMapTop20(int client, int mapID, int course, int style, int timeType)
{
	char query[1024];
	
	DataPack data = new DataPack();
	data.WriteCell(client);
	data.WriteCell(course);
	data.WriteCell(style);
	data.WriteCell(timeType);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Get map name
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	// Check for existence of map course with that MapID and Course
	FormatEx(query, sizeof(query), sql_mapcourses_findid, mapID, course);
	txn.AddQuery(query);
	
	// Get top 20 times for each time type
	switch (timeType)
	{
		case TimeType_Nub:FormatEx(query, sizeof(query), sql_getmaptop, mapID, course, style, 20);
		case TimeType_Pro:FormatEx(query, sizeof(query), sql_getmaptoppro, mapID, course, style, 20);
		case TimeType_Theoretical:FormatEx(query, sizeof(query), sql_getmaptoptheoretical, mapID, course, style, 20);
	}
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenMapTop20, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTop20(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int course = data.ReadCell();
	int style = data.ReadCell();
	int timeType = data.ReadCell();
	data.Close();
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	// Get map name from results
	char mapName[64];
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
	
	// Check if there are any times
	if (SQL_GetRowCount(results[2]) == 0)
	{
		switch (timeType)
		{
			case TimeType_Nub:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times");
			case TimeType_Pro:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times (Pro)");
			case TimeType_Theoretical:CPrintToChat(client, "%t %t", "KZ Prefix", "Map Top - No Times");
		}
		MapTopMenuDisplay(client);
		return;
	}
	
	RemoveAllMenuItems(gH_MapTopSubMenu[client]);
	
	// Set submenu title
	if (course == 0)
	{
		SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title", client, 
			gC_TimeTypePhrases[timeType], mapName, gC_StylePhrases[style]);
	}
	else
	{
		SetMenuTitle(gH_MapTopSubMenu[client], "%T", "Map Top Submenu - Title (Bonus)", client, 
			gC_TimeTypePhrases[timeType], mapName, course, gC_StylePhrases[style]);
	}
	
	// Add submenu items
	char newMenuItem[256], playerName[33];
	float runTime;
	int teleports, rank = 0;
	
	while (SQL_FetchRow(results[2]))
	{
		rank++;
		SQL_FetchString(results[2], 0, playerName, sizeof(playerName));
		runTime = SKZ_DB_TimeIntToFloat(SQL_FetchInt(results[2], 1));
		switch (timeType)
		{
			case TimeType_Nub:
			{
				teleports = SQL_FetchInt(results[2], 2);
				FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %11s  %d TP      %s", 
					rank, SKZ_FormatTime(runTime), teleports, playerName);
			}
			case TimeType_Pro:
			{
				FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %11s   %s", 
					rank, SKZ_FormatTime(runTime), playerName);
			}
			case TimeType_Theoretical:
			{
				teleports = SQL_FetchInt(results[2], 2);
				FormatEx(newMenuItem, sizeof(newMenuItem), "#%-2d   %11s  %d TP      %s", 
					rank, SKZ_FormatTime(runTime), teleports, playerName);
			}
		}
		AddMenuItem(gH_MapTopSubMenu[client], "", newMenuItem, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(gH_MapTopSubMenu[client], client, MENU_TIME_FOREVER);
} 